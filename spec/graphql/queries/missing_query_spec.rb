RSpec.describe "Query.currentUser" do
  context "when the query file is missing" do
    it "raises an error" do
      expect { is_expected.to match_graphql_response }.to raise_error(
        RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse::DefaultQueryFileMissing,
      )
    end
  end
end
