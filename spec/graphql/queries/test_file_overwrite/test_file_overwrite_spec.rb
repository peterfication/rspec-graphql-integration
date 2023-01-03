RSpec.describe "Query.currentUser" do
  context "when test_file_overwrite is defined" do
    let(:test_file_overwrite) do
      File.join(File.dirname(__FILE__), "../test_file_overwrite_spec.rb")
    end

    it "loads the query and response from that location" do
      is_expected.to match_graphql_response
    end
  end
end
