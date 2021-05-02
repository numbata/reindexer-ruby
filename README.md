[![Gem](https://img.shields.io/gem/v/reindexer.svg)](https://rubygems.org/gems/reindexer/)
![Reindexer](https://github.com/numbata/reindexer-ruby/actions/workflows/main.yml/badge.svg)

# Reindexer Ruby

gRPC client for work with [reindexer](https://github.com/Restream/reindexer). It is still in alpha state and there are a lot of works to do. So using in a prod environment is not recomended.

The gem also wraps the arguments of gRPC requests into the gRPC messages. So you should not care about the toons of nested initializations. Just give a common hash and the gem will do all the work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reindexer'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install reindexer
```

## Usage

```ruby
client = ReindexerGrpc::Client.new('grpc://reindexer:16534')
client.create_database(db_name: 'test_db')
client.open_namespace(db_name: 'test_db', storage_options: {ns_name: 'items'})
client.add_index(db_name: 'test_db', ns_name: 'items', definition: {
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
})
client.modify_item([
  {db_name: 'test_db', ns_name: 'items', mode: :UPSERT, data: JSON.dump(id: 1, name: 'Name')},
  {db_name: 'test_db', ns_name: 'items', mode: :UPSERT, data: JSON.dump(id: 2, name: 'BestName')}
])
stream = client.select_sql(db_name: 'test_db', sql: 'SELECT * FROM items', output_flags: {with_rank: true})
```

## Contributing

If you have any questions about Reindexer, please use [main page](https://github.com/Restream/reindexer) of Reindexer. Feel free to report issues and contribute about Reindexer Ruby at https://github.com/numbata/reindexer-ruby.

## License

The gem is available as open source under the terms of the [Apache-2.0](https://opensource.org/licenses/Apache-2.0)
