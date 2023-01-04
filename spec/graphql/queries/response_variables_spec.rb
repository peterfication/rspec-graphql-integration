RSpec.describe "Query.currentUser" do
  context "when response_variables are defined" do
    let(:response_variables) do
      # We need to put the mocking of User.first here so the actual_response does not
      # trigger it but only the expected_response. This way, we simulate the creation
      # of a database object during the loading of the response file.
      allow(User).to receive(:first).and_return(user)

      { user_name: "Maria Doe" }
    end
    let(:user) { { id: 1, name: "Maria Doe" } }

    it { is_expected.to match_graphql_response }
  end
end
