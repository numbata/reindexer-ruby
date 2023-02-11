# frozen_string_literal: true

module Reindexer
  class Index
    DEFAULT_OPTIONS = {
      primary_key: false,
      array: false,
      dense: false,
      sparse: false,
      collate_mode: 'CollateUTF8Mode',
      sort_order_labled: '',
      config: ''
    }.freeze

    attr_reader :name
    attr_reader :options
    attr_reader :type
    attr_reader :value_method

    def initialize(name, type, **options, &block)
      @name = name
      @type = if type.is_a?(Array)
                options[:array] = true
                type.shift
              else
                type
              end

      @value_method = options.delete(:value)
      @options = DEFAULT_OPTIONS.merge(options)

      instance_eval(&block) if block
    end

    def create!(namespace:)
      ::Reindexer.client.add_index(
        db_name: ::Reindexer.client.database,
        ns_name: namespace.name,
        definition:
      )
    end

    def definition
      {
        name: name,
        json_paths: [name],
        index_type: options.fetch(:index_type, 'hash'),
        field_type: type.to_s,
        options: index_options,
      }
    end

    def extract_value(item)
      value =
        if !value_method.nil?
          value_method.call(item)
        elsif item.respond_to?(name.to_sym)
          item.send(name.to_sym)
        else
          item[index.name]
        end

      if options[:array]
        value.map { |i| cast_value(i) }
      else
        cast_value(value)
      end
    end

    private

    def index_options
      options.each_with_object({}) do |(key, value), accum|
        case key
        when :primary_key
          accum[:is_pk] = value
        when :array
          accum[:is_array] = value
        when :dense
          accum[:is_dense] = value
        when :sparse
          accum[:sparse] = value
        when :collate_mode, :sort_order_labled, :config
          accum[key] = value
        end
      end
    end

    def cast_value(value)
      case type
      when :int, :integer
        value.to_i
      when :float
        value.to_f
      when :text, :string
        value.to_s
      else
        value
      end
    end
  end
end
