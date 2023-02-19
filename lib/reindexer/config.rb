# frozen_string_literal: true

require 'json'

module Reindexer
  class Config
    def initialize(conn_string, opts = {})
      @config = parse_config(conn_string, opts)
    end

    def [](key)
      @config[key.to_sym]
    end

    def scheme
      @config[:scheme]
    end

    def host
      @config[:host]
    end

    def port
      @config[:port]
    end

    def database
      @config[:database]
    end

    def json_adapter
      @json_adapter ||= config.fetch(:adapter, JSON)
    end

    private

    def parse_config(conn_string, opts)
      case conn_string
      when String
        uri = URI(conn_string)
        {
          host: uri.host,
          port: uri.port,
          scheme: uri.scheme.to_sym,
          database: uri.path.gsub(%r{^/}, '')
        }.merge(opts)
      when Hash
        config
          .symbolize_keys
          .slice(:host, :port, :scheme, :database, :json_adapter)
      else
        raise 'Can not parse Reindexer config'
      end
    end
  end
end
