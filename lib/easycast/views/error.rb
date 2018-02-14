module Easycast
  module Views
    #
    # Error view, providing information when the loading goes wrong
    #
    class Error < View

      def initialize(config, load_error)
        super(config)
        @load_error = load_error
      end
      attr_reader :load_error

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

    end
  end
end
