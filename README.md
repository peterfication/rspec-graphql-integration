# RSpec GraphQL Integration Testing

This RSpec plugin simplifies integration tests for [GraphQL](https://graphql-ruby.org/).

**This is still an alpha version.**

## Matchers

This plugin mainly consists of a matcher called `match_graphql_response` that executes a query or mutation against the defined schema and checks the response against a JSON response. Internally, there is also a `deep_eq` matcher to ignore the order in JSON arrays and objects.

## Idea behind this plugin

### The problem

When writing GraphQL integration tests, you write your query in a multiline string, get the response, parse it (probably with a helper) and write some expectations, maybe even expecting a whole multi-dimensional `Hash`. This could then look something like this:

```ruby
RSpec.describe "Query.currentUser" do
  subject(:query_result) { MySchema.execute(query, context: context).as_json }

  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:query) { <<~GRAPHQL }
      query {
        currentUser {
          id
          email
        }
      }
    GRAPHQL
  let(:expected_result) do
    { "data" => { "currentUser" => { "id" => user.id.to_s, "email" => user.email } } }.as_json
  end

  it "returns the current user" do
    expect(query_result).to eq(expected_result)
  end
end
```

For small queries, this is fine. But for big queries (and hence, big responses) this gets unhandy very fast. This is subjective of course ;)

Another issue is that we can't leverage the GraphQL language server while writing/maintaining these integration tests.

### The solution provided by this gem

This gem tries to improve this situation by moving the query and the response in their own files with a proper file type. This way, the integration test files are smaller and can focus on mocking data/instances. Also, the GraphQL language server will give you autocompletion/linting in your GraphQL files (if you've set up your editor for it).

The simple integration test from above then looks like this:

_`current_user_spec.rb`_

```ruby
RSpec.describe "Query.currentUser" do
  # The test_dir is needed to load the query and response files. Maybe this can be achieved differently.
  let(:test_dir) { __FILE__ }
  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:response_variables) { { user_id: user.id, user_email: user.email } }

  it { is_expected.to match_graphql_response }
end
```

_`current_user_query.graphql`_

```graphql
query {
  currentUser {
    id
    email
  }
}
```

_`current_user_response.json`_

```json
{
  "data": {
    "currentUser": {
      "id": "{{user_id}}",
      "email": "{{user_email}}"
    }
  }
}
```

> TODO: Think about using a templating language for the response

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
