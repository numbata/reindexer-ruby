# frozen_string_literal: true

module Reindexer
  class Namespace
    attr_reader :name

    def initialize(name:, &block)
      @name = name
      @indexes = []

      instance_eval(&block)
    end

    def index(name, type, **options)
      @indexes << ::Reindexer::Index.new(name, type, **options)
    end

    def search(query)
      sql =  "SELECT * FROM #{name} WHERE #{query}"
      stream = Reindexer.client.select_sql(
        db_name: ::Reindexer.client.database,
        sql: sql,
        output_flags: {with_rank: true}
      )

      extract_results(stream)
    end

    def create!
      ::Reindexer.client.open_namespace(
        db_name: ::Reindexer.client.database,
        storage_options: {ns_name: name}
      )
      @indexes.each { |index| index.create!(namespace: self) }
    end

    def add(*items)
      ::Reindexer.client.modify_item(
        items.map do |item|
          {
            db_name: ::Reindexer.client.database,
            ns_name: name,
            mode: :UPSERT,
            data: build_data(item)
          }
        end
      )
    end

    private

    def build_data(item)
      item_copy = item.dup

      data = @indexes.each_with_object({}) do |index, accum|
        accum[index.name] = index.extract_value(item_copy)
      end

      ::Reindexer.json_backend.dump(data)
    end

    # TODO: Should be a part of SearchSomethingSomething
    def extract_results(stream)
      Enumerator.new do |results|
        stream.each do |raw_items|
          items = ::Reindexer
            .json_backend
            .parse(raw_items.data, symbolize_names: true)

          next unless items.key?(:items)

          items[:items].each do |item|
            results << item
          end
        end
      end
    end
  end
end
