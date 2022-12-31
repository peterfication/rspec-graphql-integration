module RSpec
  ##
  # This module sets up GraphQL integration testing for RSpec.
  module GraphqlIntegration
    def self.initialize_configuration(config) # rubocop:disable Metrics/MethodLength
      config.add_setting(:graphql_schema_class, default: nil)

      config.include(RSpec::GraphqlIntegration::Matchers::DeepEq, type: :graphql)
      config.include(RSpec::GraphqlIntegration::Matchers::MatchGraphqlResponse, type: :graphql)

      config.instance_exec do
        # This method is inspired by the one from the RSpec::Rails gem.
        # See https://github.com/rspec/rspec-rails/blob/main/lib/rspec/rails/configuration.rb
        # => #infer_spec_type_from_file_location!
        #
        # It has to be called explicitly in the spec_helper.rb file to be enabled.
        # See the README for more information.
        def infer_graphql_spec_type_from_file_location!
          escaped_path = Regexp.compile("#{%w[spec graphql].join("[\\\\/]")}[\\/]")

          define_derived_metadata(file_path: escaped_path) do |metadata|
            metadata[:type] ||= :graphql
          end
        end
      end
    end

    initialize_configuration RSpec.configuration
  end
end
