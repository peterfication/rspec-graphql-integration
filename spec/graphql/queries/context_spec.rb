RSpec.describe "Query.currentUser" do
  context "when context is defined" do
    let(:context) { { user_name: "John Doe" } }

    it { is_expected.to match_graphql_response }
  end
end
