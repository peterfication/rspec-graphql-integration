RSpec.describe "Query.currentUser" do
  context "when the query file overwrite is present" do
    let(:query_file_overwrite) { File.join(File.dirname(__FILE__), "current_user.graphql") }

    it "takes that as the query file" do
      is_expected.to match_graphql_response
    end
  end
end
