# frozen_string_literal: true

require 'net/http'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'reindexer/reindexer_version'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :reindexer do
  desc 'Update Reindexer proto'
  task :update_proto do
    uri = URI("https://raw.githubusercontent.com/Restream/reindexer/v#{Reindexer::REINDEXER_VERSION}/cpp_src/server/proto/reindexer.proto")
    proto_content = Net::HTTP.get(uri)
    File.open('./proto/reindexer-grpc.proto', 'w') { |f| f.write(proto_content) }

    sh 'bundle exec grpc_tools_ruby_protoc -I ./proto --ruby_out=./lib --grpc_out=./lib ./proto/reindexer-grpc.proto'
  end
end

task default: %i[build test]
