module Easycast
  module Views
    #
    # Error view, providing information when the loading goes wrong
    #
    class Error < Mustache

      def initialize(config, load_error)
        @config = config
        @load_error = load_error
      end
      attr_reader :config, :load_error

      def all_resources
        []
      end

      def body_class
        "error"
      end

      def title
        "Error | Easycast"
      end

      def error_msg
        load_error.message
      end

      def error_backtrace
        load_error.backtrace.join("\n")
      end

      def main_script
        nil
      end

    end
  end
end
