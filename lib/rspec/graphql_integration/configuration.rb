module RSpec
  ##
  # This module sets up GraphQL integration testing for RSpec.
  module GraphqlIntegration
    def self.initialize_configuration(config)
      config.add_setting :graphql_schema_class, default: nil

      config.include RSpec::GraphqlIntegration::Matchers::DeepEq, type: :graphql
      config.include RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse, type: :graphql

      config.instance_exec do
        # TODO: check how rspec-rails does this
        def infer_spec_type_from_file_location!
          escaped_path = Regexp.compile(%w[spec graphql].join('[\\\/]') + '[\\\/]')

          define_derived_metadata(file_path: escaped_path) do |metadata|
            metadata[:type] ||= :graphql
          end
        end
      end
    end

    initialize_configuration RSpec.configuration
  end
end
