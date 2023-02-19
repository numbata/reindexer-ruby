# frozen_string_literal: true

require_relative '../../reindexer-grpc_services_pb'

module Reindexer
  module Adapters
    class Grpc
      DEFAULT_PORT = 16534

      attr_reader :connection, :config

      def self.build_request_name(name)
        name.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym
      end

      ::Reindexer::Grpc::Reindexer::Service.rpc_descs.each do |rpc_name, rpc_desc|
        stream_input = rpc_desc.bidi_streamer? || rpc_desc.client_streamer?
        request_name = build_request_name(rpc_name)

        if stream_input
          request_klassname = rpc_desc.input.type

          define_method(request_name) do |options_enum = []|
            request = options_enum
              .map { |options| build_grpc_request(request_klassname, **options) }

            grpc_call(request_name.to_sym, request)
          end
        else
          request_klassname = rpc_desc.input

          define_method(request_name) do |**options|
            request = build_grpc_request(request_klassname, **options)
            grpc_call(request_name.to_sym, request)
          end
        end
      end

      def initialize(config)
        @config = config

        @connection = ::Reindexer::Grpc::Reindexer::Stub.new(
          "#{config.host}:#{config.port || DEFAULT_PORT}",
          :this_channel_is_insecure
        )
      end

      def database
        @config.database
      end

      private

      def grpc_call(grpc_method, request)
        @connection.send(grpc_method, request)
      end

      def build_grpc_request(request_klass, **options)
        request_options = request_klass.descriptor.each_with_object({}) do |field_descriptor, accum|
          name = field_descriptor.name
          key_name = [name.to_sym, self.class.build_request_name(name)].find { |n| options.key?(n) }
          next if key_name.nil?

          accum[name.to_sym] = build_grpc_option_value(field_descriptor, options[key_name])
        end

        request_klass.new(**request_options)
      end

      def build_grpc_option_value(field_descriptor, value)
        type = field_descriptor.type

        if type == :message
          build_grpc_request(field_descriptor.subtype.msgclass, **value)
        elsif field_descriptor.name == :data && type == :bytes
          json_adapter.dump(value)
        else
          value
        end
      end
    end
  end
end
