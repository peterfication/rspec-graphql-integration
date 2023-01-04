module RSpec
  module GraphqlIntegration
    module Matchers
      ##
      # This helper method recursively compares nested Ruby Hashes and Arrays while ignoring
      # the order of elements in Arrays.
      module DeepEq
        module_function

        def deep_eq?(actual, expected)
          return arrays_deep_eq?(actual, expected) if expected.is_a?(Array) && actual.is_a?(Array)

          return hashes_deep_eq?(actual, expected) if expected.is_a?(Hash) && actual.is_a?(Hash)

          expected == actual
        end

        def arrays_deep_eq?(actual, expected)
          expected = expected.clone

          actual.each do |actual_array|
            index = expected.find_index { |expected_array| deep_eq?(actual_array, expected_array) }
            return false if index.nil?

            expected.delete_at(index)
          end

          expected.empty?
        end

        def hashes_deep_eq?(actual, expected)
          return false if actual.keys.sort != expected.keys.sort

          # TODO: use any or all
          actual.each { |key, value| return false unless deep_eq?(value, expected[key]) }

          true
        end
      end
    end
  end
end
