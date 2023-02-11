# frozen_string_literal: true

require 'reindexer/version'

module Reindexer
  autoload :Client, 'reindexer/client'

  autoload :Dsl, 'reindexer/dsl'
  autoload :Namespace, 'reindexer/namespace'
  autoload :Index, 'reindexer/index'

  class << self
    def configure(options)
      @client = ::Reindexer::Client.new(options)
    end
    alias :config :configure

    def client
      @client
    end
  end
end
