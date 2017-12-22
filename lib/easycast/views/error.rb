module Easycast
  module Views
    #
    # Error view, providing information when the loading goes wrong
    #
    class Error < Layout

      def subtitle
        "Error"
      end

      def error_msg
        @load_error.message
      end

      def error_backtrace
        @load_error.backtrace.join("\n")
      end

    end
  end
end
