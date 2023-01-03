RSpec.describe RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse do
  subject(:mock_instance) do
    Class.new { extend RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse }
  end

  describe "#load_response" do
    let(:dir) { __FILE__ }
    let(:filename) { "example_response.json" }
    let(:variables) { { user_name: "John Doe" } }

    let(:expected_response) { { "data" => { "user" => { "name" => "John Doe" } } } }

    it "loads the response from a file" do
      expect(mock_instance.load_response(dir, filename, variables)).to eq(expected_response)
    end
  end

  describe "#load_query" do
    let(:dir) { __FILE__ }
    let(:filename) { "example_query.graphql" }

    let(:expected_response) { <<~GRAPHQL }
        query Test {
          currentUser {
            id
            email
          }
        }
      GRAPHQL

    it "loads the query from a file" do
      expect(mock_instance.load_query(dir, filename)).to eq(expected_response)
    end
  end
end
