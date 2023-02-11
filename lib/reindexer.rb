# frozen_string_literal: true

require 'reindexer/version'

module Reindexer
  autoload :Client, 'reindexer/client'

  autoload :Dsl, 'reindexer/dsl'
  autoload :Namespace, 'reindexer/namespace'
  autoload :Index, 'reindexer/index'

  class << self
    attr_reader :client

    def configure(options)
      @client = ::Reindexer::Client.new(options)
    end
    alias config configure

    def json_backend
      @json_backend ||= defined?(MultiJSON) ? MultiJSON : JSON
    end
  end
end
