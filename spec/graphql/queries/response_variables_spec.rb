RSpec.describe "Query.currentUser" do
  context "when response_variables are defined" do
    let(:response_variables) { { user_name: "John Doe" } }

    it { is_expected.to match_graphql_response }
  end
end
