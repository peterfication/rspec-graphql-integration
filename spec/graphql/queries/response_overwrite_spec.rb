RSpec.describe "Query.currentUser" do
  context "when the response file overwrite is present" do
    let(:response_file_overwrite) { File.join(File.dirname(__FILE__), "current_user.json") }

    it "takes that as the response file" do
      is_expected.to match_graphql_response
    end
  end
end
