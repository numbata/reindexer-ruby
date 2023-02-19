# frozen_string_literal: true

require 'json'

module Reindexer
  class Client
    class << self
      def build(options)
        config = Reindexer::Config.new(options)
        klass = adapter_class(config.scheme)

        klass.new(config)
      end

      private

      def adapter_class(scheme)
        case scheme
        when :grpc
          Reindexer::Adapters::Grpc
          # when :http, :https, :rest
          #   Reindexer::Api::Rest.new(config)
        end
      end
    end
  end
end
