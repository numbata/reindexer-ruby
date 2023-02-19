# frozen_string_literal: true

require 'reindexer/version'
require 'reindexer/client'
require 'reindexer/config'
require 'reindexer/dsl'
require 'reindexer/namespace'
require 'reindexer/index'
require 'reindexer/adapters/grpc'

module Reindexer
  class << self
    attr_reader :client

    def connect(options)
      @client = ::Reindexer::Client.build(options)
    end

    def json_backend
      @json_backend ||= defined?(MultiJSON) ? MultiJSON : JSON
    end
  end
end
