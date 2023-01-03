RSpec.describe "Query.otherUser" do
  context "when the schema_class_overwrite is present" do
    let(:schema_class_overwrite) { TestSchemaB }

    it { is_expected.to match_graphql_response }
  end

  context "when the schema class is not set in the RSpec config" do
    before { allow(RSpec.configuration).to receive(:graphql_schema_class).and_return(nil) }

    it "raises an error" do
      expect { is_expected.to match_graphql_response }.to raise_error(
        RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse::SchemaNotSetError,
      )
    end
  end
end
