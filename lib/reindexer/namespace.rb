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

    def create!
      ::Reindexer.client.open_namespace(
        db_name: ::Reindexer.client.database,
        storage_options: {ns_name: name}
      )
      @indexes.each { |index| index.create!(namespace: self) }
    end

    def add(item)
        ::Reindexer.client.modify_item(
          [
            {
              db_name: ::Reindexer.client.database,
              ns_name: name,
              mode: :UPSERT,
              data: build_data(item)

            }
          ]
        )
    end

    private

    def build_data(item)
      item_copy = item.dup

      data = @indexes.each_with_object({}) do |index, accum|
        accum[index.name] = index.extract_value(item_copy)
      end

      (defined?(MultiJSON) ? MultiJSON : JSON).dump(data)
    end
  end
end
