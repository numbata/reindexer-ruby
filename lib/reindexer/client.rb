# frozen_string_literal: true

require_relative '../reindexer-grpc_services_pb'
require 'json'

module Reindexer
  class Client
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

    def initialize(options)
      @config = parse_config(options)
      @connection = ::Reindexer::Grpc::Reindexer::Stub.new(
        "#{config[:host]}:#{config[:port] || DEFAULT_PORT}",
        :this_channel_is_insecure
      )
    end

    private

    def json_adapter
      @json_adapter ||= config.fetch(:adapter, JSON)
    end

    def parse_config(options)
      case options
      when String
        uri = URI(options)
        {
          host: uri.host,
          port: uri.port,
          scheme: uri.scheme.to_sym,
          database: uri.path.gsub(%r{^/}, '')
        }
      when Hash
        config.slice(:host, :port, :scheme, :database, :json_adapter)
      else
        raise 'Can not parse Reindexer config'
      end
    end

    def grpc_call(grpc_method, request)
      @connection.send(grpc_method, request)
    end

    def build_grpc_request(request_klass, **options)
      request_options = request_klass.descriptor.each_with_object({}) do |field_descriptor, accum|
        name = field_descriptor.name
        key_name = [name.to_sym, self.class.build_request_name(name)].find { |n| options.key?(n) }
        next if key_name.nil?

        accum[name] = build_grpc_option_value(field_descriptor, options[key_name])
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
