# frozen_string_literal: true

RSpec.describe Reindexer::Dsl do
  let(:klass) do
    Struct.new(:id, :name, :comments, keyword_init: true) do
      include Reindexer::Dsl

      reindex :items do
        index :id, :int, primary_key: true
        index :name, :text, value: -> (obj) { obj.name.downcase }
        index :comments, [:text]

        # Alternative (???)
        # int :id, primary_key: true
        # text :name, -> { name.downcase }
        # text [:comments
      end
    end
  end

  before do
    Reindexer.configure("grpc://#{ENV.fetch('REINDEXER_HOST', 'localhost')}:16534/test_db")
    Reindexer.client.drop_namespace(db_name: 'test_db', ns_name: 'items')
    klass.index_create!
  end

  context ".index_update!" do
    let(:objects) do
      [
        klass.new(id: 1, name: 'Name', comments: ['Comment A', 'Comment B']),
        klass.new(id: 2, name: 'Surname', comments: ['Comment C']),
      ]
    end

    before do
      objects.each { |obj| klass.index_update!(obj) }
      # Wait for indexing
      sleep 0.5
    end

    it "updates index successfuly" do
      result = klass.index_search('foo').to_a

      expect(result)
        .to include(hash_including(id: 1, name: 'name'))
        .and include(hash_including(id: 2, name: 'surname'))
    end
  end

  context "#index_update!" do
    let(:obj) { klass.new(id: 1, name: 'Name', comments: ['Comment A', 'Comment B']) }

    before do
      obj.index_update!

      # Wait for indexing
      sleep 0.5
    end

    it "updates index successfuly" do
      result = klass.index_search(obj.name).to_a

      expect(result)
        .to include(hash_including(id: 1, name: 'name'))
    end
  end
end
