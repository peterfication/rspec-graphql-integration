<p align="center">
  <img src="logo.png" width="200" \>
</p>

<h1 align="center">RSpec GraphQL Integration Testing</h1>

<p align="center">
  <a href="https://github.com/peterfication/rspec-graphql-integration/actions?query=branch%3Amain+">
    <img alt="CI" src="https://github.com/peterfication/rspec-graphql-integration/actions/workflows/ci.yml/badge.svg" \>
  </a>
  <a href="https://codecov.io/gh/peterfication/rspec-graphql-integration">
    <img alt="CodeCov" src="https://codecov.io/gh/peterfication/rspec-graphql-integration/branch/main/graph/badge.svg?token=V5HKH4C2BA" \>
  </a>
  <a href="https://sonarcloud.io/summary/new_code?id=peterfication_rspec-graphql-integration">
    <img alt="Maintainability Rating" src="https://sonarcloud.io/api/project_badges/measure?project=peterfication_rspec-graphql-integration&metric=sqale_rating" \>
  </a>
</p>

<p align="center">
  This <a href="https://rspec.info/">RSpec</a> plugin simplifies integration tests for <a href="https://graphql-ruby.org/">GraphQL</a>.
</p>

## Introduction

This plugin mainly consists of a matcher called `match_graphql_response` that executes a query or mutation against the defined schema and checks the response against a JSON response.

### Idea behind this plugin

#### The problem

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

#### The solution provided by this gem

This gem tries to improve this situation by moving the query and the response in their own files with a proper file type. This way, the integration test files are smaller and can focus on mocking data/instances. Also, the GraphQL language server will give you autocompletion/linting in your GraphQL files (if you've set up your editor for it).

The simple integration test from above then looks like this:

_`current_user_spec.rb`_

```ruby
RSpec.describe "Query.currentUser" do
  let(:user) { create(:user) }
  let(:context) { { current_user: user } }
  let(:response_variables) { { user_id: user.id, user_email: user.email } }

  it { is_expected.to match_graphql_response }
end
```

_`current_user.graphql`_

```graphql
query {
  currentUser {
    id
    email
  }
}
```

_`current_user.json`_

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

You can have a look at the [RSpec GraphQL integration configuration](spec/support/graphql_integration.rb) of this gem to get started.

### Schema class

You need to define the schema class that is used to execute the queries against. You can also define a main schema, but overwrite this for specific tests with `let(:schema_class_overwrite) { MyOtherSchema }`.

```ruby
RSpec.configure do |config|
  # ...
  config.graphql_schema_class = MySchema
  # ...
end
```

### Files in folder

The default behavior for the request and response files is that they are named like the test file but instead of `_spec.rb` they end with `.graphql` and `.json`. If you want the files to be in a folder named like the test file, activate this option. Then the matcher will look for `<test_file_without_spec.rb>/(request.graphql|response.json)` instead of `<test_file_without_spec.rb>.(graphql|json)`.

```ruby
RSpec.configure do |config|
  # ...
  config.graphql_put_files_in_folder = true
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

## Special variables

A lot of things can be adjusted per test by setting special variables. You need to set them with `let`:

```ruby
let(:context) { { current_user: user } }
```

Here is an overview of what can be set:

| Variable                  | Description                                                                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `test_file_overwrite`     | Overwrites the location of the test file, if the automatic test file discovery is not working. This should normally not be necessary.       |
| `schema_class_overwrite`  | Overwrites the schema class that is used for the test. This is only necessary if you have more than one GraphQL schema in your codebase.    |
| `request_file_overwrite`  | Overwrites the filename of the request file, in case you want to reuse request files or put them inside a folder.                           |
| `response_file_overwrite` | Overwrites the filename of the response file, in case you want to reuse response files or put them inside a folder.                         |
| `context`                 | The GraphQL context that is passed to the GraphQL schema.                                                                                   |
| `request_variables`       | Sets the variables that are passed into the GraphQL schema execution. This is necessary if you use variables inside your queries/mutations. |
| `response_variables`      | Sets the variables that are used by the simple response template engine.                                                                    |

## License

MIT
