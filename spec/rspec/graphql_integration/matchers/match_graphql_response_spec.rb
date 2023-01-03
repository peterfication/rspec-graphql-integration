RSpec.describe RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse do
  subject(:mock_instance) do
    Class.new { extend RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse }
  end

  describe "#load_response" do
    let(:filename) { "example_response.json" }
    let(:variables) { { user_name: "John Doe" } }

    let(:expected_response) { { "data" => { "user" => { "name" => "John Doe" } } } }

    it "loads the response from a file" do
      expect(
        mock_instance.load_response(File.join(File.dirname(__FILE__), filename), variables),
      ).to eq(expected_response)
    end
  end
end
