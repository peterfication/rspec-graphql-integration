RSpec.describe "Query.currentUser" do
  context "when the put_files_in_folder option is set" do
    before { allow(RSpec.configuration).to receive(:graphql_put_files_in_folder).and_return(true) }

    it { is_expected.to match_graphql_response }
  end
end
