# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reindexer/version'

Gem::Specification.new do |spec|
  spec.name          = 'reindexer'
  spec.version       = Reindexer::VERSION
  spec.authors       = ['Andrei Subbota']
  spec.email         = ['subbota@gmail.com']
  spec.platform      = Gem::Platform::RUBY

  spec.summary       = 'Reindexer gRPC-client'
  spec.description   = 'A gRPC-client that allows to interact with the Reindexer document-oriented database'

  spec.homepage      = 'https://github.com/numbata/reindexer-ruby'
  spec.license       = 'Apache-2.0'
  spec.metadata      = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'source_code_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true'
  }
  spec.required_ruby_version = Gem::Requirement.new('>= 2')

  spec.files = Dir['lib/**/*.rb', 'LICENSE.txt']
  spec.extra_rdoc_files = %w[CHANGELOG.md README.md]

  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_dependency 'grpc', '~> 1.0'

  spec.add_development_dependency 'google-protobuf', '>= 3.21'
  spec.add_development_dependency 'grpc-tools', '~> 1.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.10'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
end
