require "json"

module RSpec
  module GraphqlIntegration
    module Matchers
      ##
      # This module contains the matchers that are used to test GraphQL queries and mutations.
      module MatchGraphqlResponse
        extend RSpec::Matchers::DSL

        ##
        # This error is raised when the schema class is not set in the RSpec configuration.
        class SchemaNotSetError < StandardError
          def initialize
            super <<~TEXT
              Please define

                config.graphql_schema_class

              in your spec_helper.rb
            TEXT
          end
        end

        ##
        # This error is thrown if neither the default request file is present nor
        # the request_file_overwrite variable is set in a test.
        class DefaultRequestFileMissing < StandardError
          def initialize(default_request_file)
            super <<~TEXT
                No default request file found for this test.

                Please create either a default request file:
                #{default_request_file}

                or define a file with the request_file_overwrite variable:
                let(:request_file_overwrite) { File.join(File.dirname(__FILE__), "my_request_file.graphql") }
              TEXT
          end
        end

        ##
        # This error is thrown if neither the default request file is present nor
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
            # expected_response needs to be loaded first because it might contain variables
            # that are required in the request and that aren't loaded yet. Such variables
            # could be database objects that could be created while loading the response.
            expected_response

            # We need to test the responses with DeepEq so that we ignore
            # the order in nested hashes.
            DeepEq.deep_eq?(actual_response, expected_response)
          end

          # For the failure message, we want to show the diff between the actual and
          # the expected response and the standard eq matcher from RSpec does that best.
          failure_message { expect(actual_response).to eq(expected_response) }

          ##
          # Loads the response file and substitutes the variables in the response file.
          def expected_response
            @expected_response ||=
              begin
                expected_response =
                  load_response(
                    response_file,
                    defined?(response_variables) ? response_variables : {},
                  )

                expected_response = [expected_response] unless expected_response.is_a?(Array)

                expected_response
              end
          end

          ##
          # Executes the query with the context and the variables against the schema and
          # returns the response.
          def actual_response
            @actual_response ||=
              begin
                response =
                  schema_class.execute(
                    File.read(request_file),
                    context: defined?(context) ? context : {},
                    variables: defined?(request_variables) ? request_variables : {},
                  )

                response.values
              end
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

          ##
          # This method defines the folder where the request and response files are stored.
          #
          # It's either the folder of the file that is running the tests or a subfolder
          # named like the test file.
          def files_folder
            if RSpec.configuration.graphql_put_files_in_folder
              test_file.gsub("_spec.rb", "")
            else
              File.dirname(test_file)
            end
          end

          ##
          # This method tries to get the file path for the request file.
          #
          # If the request_file_overwrite variable is set, it uses that.
          #
          # raises DefaultRequestFileMissing if no request file is found.
          def request_file
            if defined?(request_file_overwrite)
              return File.join(files_folder, request_file_overwrite)
            end

            default_request_file = File.join(files_folder, default_request_file_name)

            unless File.exist?(default_request_file)
              raise DefaultRequestFileMissing, default_request_file
            end

            default_request_file
          end

          ##
          # The default request file is either called like the test file without _spec
          # but with .graphql or it's in the subfolder of the test file called "request.graphql".
          def default_request_file_name
            if RSpec.configuration.graphql_put_files_in_folder
              "request.graphql"
            else
              test_file.split("/").last.gsub("_spec.rb", ".graphql")
            end
          end

          ##
          # This method tries to get the file path for the response file.
          #
          # If the response_file_overwrite variable is set, it uses that.
          #
          # raises DefaultRequestFileMissing if no response file is found.
          def response_file
            if defined?(response_file_overwrite)
              return File.join(files_folder, response_file_overwrite)
            end

            default_response_file = File.join(files_folder, default_response_file_name)

            unless File.exist?(default_response_file)
              raise DefaultResponseFileMissing, default_response_file
            end

            default_response_file
          end

          ##
          # The default response file is either called like the test file without _spec
          # but with .json or it's in the subfolder of the test file called "response.json".
          def default_response_file_name
            if RSpec.configuration.graphql_put_files_in_folder
              "response.json"
            else
              test_file.split("/").last.gsub("_spec.rb", ".json")
            end
          end

          ##
          # This method gets the schema class from the RSpec configuration.
          #
          # If schema_class_overwrite is set, it uses that.
          #
          # raises SchemaNotSetError if the schema class is not set.
          def schema_class
            # It's possible to overwrite the schema class if an app has multiple schemas.
            return schema_class_overwrite if defined?(schema_class_overwrite)

            raise SchemaNotSetError if RSpec.configuration.graphql_schema_class.nil?

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
