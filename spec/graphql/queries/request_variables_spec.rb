RSpec.describe "Query.currentUser" do
  context "when request_variables are defined" do
    let(:request_variables) { { userName: "John Doe" } }

    it { is_expected.to match_graphql_response }
  end
end
