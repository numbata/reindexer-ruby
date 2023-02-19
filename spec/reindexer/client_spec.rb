# frozen_string_literal: true

RSpec.describe Reindexer::Client do
  describe '.build' do
    it 'returns client with specific adapter' do
      expect(described_class.build("grpc://#{ENV.fetch('REINDEXER_HOST', 'localhost')}:16534"))
        .to be_a(Reindexer::Adapters::Grpc)
    end
  end
end
