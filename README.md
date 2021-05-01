[![Gem](https://img.shields.io/gem/v/reindexer.svg)](https://rubygems.org/gems/reindexer/)
![Reindexer](https://github.com/numbata/reindexer-ruby/actions/workflows/main.yml/badge.svg)

# Reindexer

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/reindexer`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reindexer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reindexer

## Usage

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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/numbata/reindexer-ruby.

## License

The gem is available as open source under the terms of the [Apache-2.0](https://opensource.org/licenses/Apache-2.0)
