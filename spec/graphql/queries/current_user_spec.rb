RSpec.describe "Query.currentUser" do
  it { is_expected.to match_graphql_response }

  context "when the response is different" do
    let(:response_file_overwrite) { File.join(File.dirname(__FILE__), "current_user_failure.json") }

    it "fails the expectation" do
      expect { is_expected.to match_graphql_response }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
      )
    end
  end
end
