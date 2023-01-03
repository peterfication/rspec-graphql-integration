RSpec.describe "Query.currentUser" do
  context "when the request file overwrite is present" do
    let(:request_file_overwrite) { "current_user.graphql" }

    it "takes that as the query file" do
      is_expected.to match_graphql_response
    end
  end
end
