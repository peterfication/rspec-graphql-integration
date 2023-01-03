require "json"

module RSpec
  module GraphqlIntegration
    module Matchers
      ##
      # This module contains the matchers that are used to test GraphQL queries and mutations.
      module MatchGraphqlResponse
        extend RSpec::Matchers::DSL

        ##
        # This error is thrown if neither the default query file is present nor
        # the query_file_overwrite variable is set in a test.
        class DefaultQueryFileMissing < StandardError
          def initialize(default_query_file)
            super <<~TEXT
                No default query file found for this test.

                Please create either a default query file:
                #{default_query_file}

                or define a file with the query_file_overwrite variable:
                let(:query_file_overwrite) { File.join(File.dirname(__FILE__), "my_query_file.graphql") }
              TEXT
          end
        end

        ##
        # This error is thrown if neither the default query file is present nor
        # the response_file_overwrite variable is set in a test.
        class DefaultResponseFileMissing < StandardError
          def initialize(default_response_file)
            super <<~TEXT
                No default response file found for this test.

                Please create either a default response file:
                #{default_response_file}

                or define a file with the response_file_overwrite variable:
                let(:response_file_overwrite) { File.join(File.dirname(__FILE__), "my_response_file.graphql") }
              TEXT
          end
        end

        matcher(:match_graphql_response) do |_expected| # rubocop:disable Metrics/BlockLength
          match do |_actual|
            # We need to test the responses with be_deep_equal so that we ignore
            # the order in nested hashes.
            expect(actual_response).to deep_eq(expected_response)
          rescue RSpec::Expectations::ExpectationNotMetError => e
            @error = e
            raise
          end

          # For the failure message, we want to show the diff between the actual and
          # the expected response and the standard eq matcher from RSpec does that best.
          failure_message { expect(actual_response).to eq(expected_response) }

          def expected_response
            expected_response =
              load_response(response_file, defined?(response_variables) ? response_variables : {})

            expected_response = [expected_response] unless expected_response.is_a?(Array)

            expected_response
          end

          def actual_response
            response =
              schema_class.execute(
                File.read(query_file),
                context: defined?(context) ? context : {},
                variables: defined?(request_variables) ? request_variables : {},
              )

            response.values
          end

          ##
          # This method tries to get the file path for the file that is running the tests.
          #
          # The magic of this method can be overwritten by defining:
          # let(:test_file_overwrite) { __FILE__ }
          def test_file
            return test_file_overwrite if defined?(test_file_overwrite)

            caller_location =
              caller_locations.find { |location| location.path.include?("/spec/graphql") }

            caller_location.path
          end

          def query_file
            return query_file_overwrite if defined?(query_file_overwrite)

            default_query_file_name = test_file.split("/").last.gsub("_spec.rb", ".graphql")
            default_query_file = File.join(File.dirname(test_file), default_query_file_name)

            raise DefaultQueryFileMissing, default_query_file unless File.exist?(default_query_file)

            default_query_file
          end

          def response_file
            return response_file_overwrite if defined?(response_file_overwrite)

            default_response_file_name = test_file.split("/").last.gsub("_spec.rb", ".json")
            default_response_file = File.join(File.dirname(test_file), default_response_file_name)

            unless File.exist?(default_response_file)
              raise DefaultResponseFileMissing, default_response_file
            end

            default_response_file
          end

          def schema_class
            # It's possible to overwrite the schema class if an app has multiple schemas.
            return schema_class_overwrite if defined?(schema_class_overwrite)

            if RSpec.configuration.graphql_schema_class.nil? && !Object.const_defined?(:Schema)
              raise "Please define config.graphql_schema_class in your rails_helper.rb"
            end

            RSpec.configuration.graphql_schema_class
          end
        end

        ##
        # Loads a response in a JSON file and substitute the passed variables that
        # are surrounded by {{...}} in the file.
        #
        # Example:
        # load_response(
        #   "current_user.json",
        #   {
        #     user_id: 1,
        #   },
        # )
        #
        # current_user.json:
        # {
        #   "data": {
        #     "currentUser": {
        #       "id": "{{user_id}}",
        #     }
        #   }
        # }
        #
        # Result:
        # {
        #   "data": {
        #     "currentUser": {
        #     "id": "1",
        #     }
        #   }
        # }
        def load_response(filename, variables = {})
          json_file = File.read(filename)
          variables.each { |key, value| json_file.gsub!("\"{{#{key}}}\"", JSON.dump(value)) }

          JSON.parse(json_file)
        end
      end
    end
  end
end
