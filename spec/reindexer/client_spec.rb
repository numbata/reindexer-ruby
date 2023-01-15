# frozen_string_literal: true

RSpec.describe Reindexer::Client do
  subject(:client) { described_class.new("grpc://#{ENV.fetch('REINDEXER_HOST', 'localhost')}:16534") }

  let(:index_definition) do
    {
      name: 'id',
      json_paths: ['id'],
      index_type: 'hash',
      field_type: 'int',
      options: {
        is_pk: true,
        is_array: false,
        is_dense: false,
        is_sparse: false,
        collate_mode: 'CollateUTF8Mode',
        sort_order_labled: '',
        config: ''
      },
      expire_after: nil
    }
  end
  let(:index_items) do
    [
      {db_name: 'test_db', ns_name: 'items', mode: :UPSERT, data: JSON.dump(id: 1, name: 'Name')},
      {db_name: 'test_db', ns_name: 'items', mode: :UPSERT, data: JSON.dump(id: 2, name: 'BestName')}
    ]
  end

  it 'indexes and retrieve items' do
    client.create_database(db_name: 'test_db')
    client.drop_namespace(db_name: 'test_db', ns_name: 'items')
    client.open_namespace(db_name: 'test_db', storage_options: {ns_name: 'items'})
    client.add_index(db_name: 'test_db', ns_name: 'items', definition: index_definition)
    client.modify_item(index_items)

    # Wait for indexing
    sleep 0.5

    stream = client.select_sql(db_name: 'test_db', sql: 'SELECT * FROM items', output_flags: {with_rank: true})
    result = stream.to_a.first
    data = JSON.parse(result.data, symbolize_names: true)
    expect(data[:items])
      .to include(id: 1, name: 'Name')
      .and include(id: 2, name: 'BestName')
  end
end
