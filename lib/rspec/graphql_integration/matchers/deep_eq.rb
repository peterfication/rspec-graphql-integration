module RSpec
  module GraphqlIntegration
    module Matchers
      ##
      # This matcher recursively compares nested Ruby Hashes and Arrays while ignoring the order of
      # elements in Arrays.
      module DeepEq
        extend RSpec::Matchers::DSL

        matcher :deep_eq do |expected|
          match do |actual|
            deep_eq?(actual, expected)
          end
        end

        def deep_eq?(actual, expected)
          return arrays_match?(actual, expected) if expected.is_a?(Array) && actual.is_a?(Array)
          return hashes_match?(actual, expected) if expected.is_a?(Hash) && actual.is_a?(Hash)

          expected == actual
        end

        def arrays_match?(actual, expected)
          expected = expected.clone

          actual.each do |array|
            index = expected.find_index { |element| deep_eq?(array, element) }
            return false if index.nil?

            expected.delete_at(index)
          end

          expected.empty?
        end

        def hashes_match?(actual, expected)
          return false if actual.keys.sort != expected.keys.sort

          # TODO: use any or all
          actual.each do |key, value|
            return false unless deep_eq?(value, expected[key])
          end
          true
        end
      end
    end
  end
end
