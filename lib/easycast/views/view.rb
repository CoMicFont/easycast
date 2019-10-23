module Easycast
  module Views
    #
    # Main class for all views.
    #
    class View < Mustache

      def initialize(config, state)
        raise ArgumentError, "Missing state" unless state
        raise ArgumentError, "Missing state walk" unless state.walk
        @config = config
        @state = state
      end
      attr_reader :config, :state

      def all_resources
        []
      end

      def walk
        state.walk
      end

      def scheduler
        state.scheduler
      end

      def state_json
        {
          walkIndex: state.walk.state,
          paused: state.scheduler.paused?
        }.to_json
      end

      def main_script
        nil
      end

    end
  end
end
