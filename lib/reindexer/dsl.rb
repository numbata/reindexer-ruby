# frozen_string_literal: true

module Reindexer
  module Dsl
    module ClassMethods
      def reindex(name = nil, &block)
        @reindex ||= if block
                       Reindexer::Namespace.new(
                         name: name || self.caller.class_name.downcase.to_sym,
                         &block
                       )
                     end
      end

      # TODO: drafty draft. Should be extracted
      def reindex_search(_query)
        raise 'Index is not defined' if @reindex.nil?

        @reindex.search(query)
      end

      def reindex_create!
        @reindex.create!
      end

      def reindex_add!(*item)
        @reindex.add(*item)
      end
    end

    module InstanceMethods
      def reindex_update!
        self.class.reindex_add!(self)
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)
    end
  end
end
