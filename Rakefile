# frozen_string_literal: true

require 'net/http'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'reindexer/reindexer_version'

RSpec::Core::RakeTask.new(:spec)
desc 'Run RSpec code examples'
task test: :spec

namespace :reindexer do
  desc 'Update Reindexer proto'
  task :update_proto do
    uri = URI("https://raw.githubusercontent.com/Restream/reindexer/v#{Reindexer::REINDEXER_VERSION}/cpp_src/server/proto/reindexer.proto")
    proto_content = Net::HTTP.get(uri)
    File.write('./proto/reindexer-grpc.proto', proto_content)

    sh 'bundle exec grpc_tools_ruby_protoc -I ./proto --ruby_out=./lib --grpc_out=./lib ./proto/reindexer-grpc.proto'
  end
end

task default: %i[build test]
