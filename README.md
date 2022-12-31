# RSpec GraphQL Integration Testing

This RSpec plugin simplifies integration tests for [GraphQL](https://graphql-ruby.org/).

This is a very early alpha version.

## Configuration

### Schema class

You need to define the schema class that is used to execute the queries against. You can also define a main schema, but overwrite this for specific tests with `let(:schema_class_overwrite) { MyOtherSchema }`.

```ruby
RSpec.configure do |config|
  # ...
  config.graphql_schema_class = MySchema
  # ...
end
```

### Spec type from file location

Like with the [`RSpec::Rails`](https://github.com/rspec/rspec-rails), this gem can infer the spec type (`graphql`) from the spec file location. If you want this to happen, you have to enable this explicitly:

```ruby
RSpec.configure do |config|
  # ...
  config.infer_graphql_spec_type_from_file_location!
  # ...
end
```
