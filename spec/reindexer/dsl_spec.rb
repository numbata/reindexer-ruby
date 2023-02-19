# frozen_string_literal: true

RSpec.describe Reindexer::Dsl do
  let(:klass) do
    Struct.new(:id, :name, :comments, keyword_init: true) do
      include Reindexer::Dsl

      reindex :items do
        index :id, :int, primary_key: true
        index :name, :text, value: ->(obj) { obj.name.downcase }
        index :comments, [:text]
      end
    end
  end
  let(:client) { Reindexer.connect("grpc://#{ENV.fetch('REINDEXER_HOST', 'localhost')}:16534/test_db") }

  before do
    client.drop_namespace(db_name: 'test_db', ns_name: 'items')
    klass.reindex.create!
  end

  describe '.index_update!' do
    let(:objects) do
      [
        klass.new(id: 1, name: 'Name', comments: ['Comment A', 'Comment B']),
        klass.new(id: 2, name: 'Surname', comments: ['Comment C'])
      ]
    end

    before do
      objects.each { |obj| klass.reindex.add(obj) }
      # Wait for indexing
      sleep 0.5
    end

    it 'updates index successfuly' do
      result = klass.reindex.search("name LIKE '%Name'").to_a

      expect(result)
        .to include(hash_including(id: 1, name: 'name'))
        .and include(hash_including(id: 2, name: 'surname'))
    end
  end

  describe '#reindex_update!' do
    let(:obj) { klass.new(id: 1, name: 'Name', comments: ['Comment A', 'Comment B']) }

    before do
      obj.reindex_update!
      sleep 0.5
    end

    it 'updates index successfuly' do
      result = klass.reindex.search("name = '#{obj.name.downcase}'").to_a

      expect(result)
        .to include(hash_including(id: 1, name: 'name'))
    end
  end
end
