# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Check that `be_nil` is used instead of `be(nil)`.
      #
      # RSpec has a built-in `be_nil` matcher specifically for expecting `nil`.
      # For consistent specs, we recommend using that instead of `be(nil)`.
      #
      # @example
      #
      #   # bad
      #   expect(foo).to be(nil)
      #
      #   # good
      #   expect(foo).to be_nil
      #
      class BeNil < Base
        extend AutoCorrector

        MSG = 'Prefer `be_nil` over `be(nil)`.'
        RESTRICT_ON_SEND = %i[be].freeze

        # @!method nil_value_expectation?(node)
        def_node_matcher :nil_value_expectation?, <<-PATTERN
          (send nil? :be nil)
        PATTERN

        def on_send(node)
          return unless nil_value_expectation?(node)

          add_offense(node) do |corrector|
            corrector.replace(node.loc.expression, 'be_nil')
          end
        end
      end
    end
  end
end
