require "json"

module RSpec
  module GraphqlIntegration
    module Matchers
      ##
      # This module contains the matchers that are used to test GraphQL queries and mutations.
      module MatchGraphqlResponse
        extend RSpec::Matchers::DSL

        ##
        # This error is thrown when a variable is missing that is required for
        # the GraphQL response matcher.
        class TestVariableMissing < ArgumentError
          def initialize(variable_name, example_value)
            super <<~TEXT
              Test variable #{variable_name} is missing.

              Please define it, e.g. with:
              let(:#{variable_name}) { #{example_value} }
            TEXT
          end
        end

        ##
        # Defines the required variables as a hash for a test that uses
        # the GraphQL response matcher.
        #
        # Key is the variable name, value is an example value.
        REQUIRED_TEST_VARIABLES = { test_dir: "__FILE__" }.freeze

        matcher(:match_graphql_response) do |_expected| # rubocop:disable Metrics/BlockLength
          match do |_actual|
            check_variables!

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

          def check_variables!
            REQUIRED_TEST_VARIABLES.each do |variable_name, example_value|
              unless defined?(send(variable_name))
                raise TestVariableMissing.new(variable_name, example_value)
              end
            end
          end

          def expected_response
            expected_response = load_response(test_dir, response_template, response_variables)

            expected_response = [expected_response] unless expected_response.is_a?(Array)

            expected_response
          end

          def actual_response
            response =
              schema_class.execute(
                load_query(test_dir, query_file),
                context: context,
                variables: defined?(request_variables) ? request_variables : {},
              )

            response.values
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
        # Loads a query in a GraphQL file.
        #
        # Example:
        # load_query(__FILE__, 'current_user/query.graphql'),
        def load_query(dir, filename)
          File.read(File.join(File.dirname(dir), filename))
        end

        ##
        # Loads a response in a JSON file and substitute the passed variables that
        # are surrounded by {{...}} in the file.
        #
        # Example:
        # load_response(
        #   __FILE__,
        #   'current_user/response.json',
        #   {
        #     user_id: user.id,
        #   },
        # )
        def load_response(dir, filename, variables = {})
          json_file = File.read(File.join(File.dirname(dir), filename))
          variables.each { |key, value| json_file.gsub!("\"{{#{key}}}\"", JSON.dump(value)) }

          JSON.parse(json_file)
        end
      end
    end
  end
end
