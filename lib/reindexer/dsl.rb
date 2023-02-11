# frozen_string_literal: true

module Reindexer
  module Dsl
    module ClassMethods
      def reindex(name = nil, &blank)
        @namespace = Reindexer::Namespace.new(name: name || self.caller.class_name.downcase.to_sym, &blank)
      end

      # TODO: drafty draft. Should be extracted
      def index_search(_query)
        raise 'Index is not defined' if @namespace.nil?

        stream = Reindexer.client.select_sql(
          db_name: ::Reindexer.client.database,
          sql: "SELECT * FROM #{@namespace.name}",
          output_flags: {with_rank: true}
        )

        extract_results(stream)
      end

      def index_create!
        @namespace.create!
      end

      def index_update!(item)
        @namespace.add(item)
      end

      private

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

    module InstanceMethods
      def index_update!
        self.class.index_update!(self)
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)
    end
  end
end
