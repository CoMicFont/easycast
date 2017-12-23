module Easycast
  module Views
    #
    # Display view, providing the context to display.mustache
    #
    class Display < Layout

      def subtitle
        "Display #{display_index}"
      end

      def body_class
        super + (with_remote ? " with-remote" : " without-remote")
      end

      def with_remote
        display_cast[:remote]
      end

      def display_index
        @display_index
      end

      def display_cast
        @display_cast ||= current_scene.cast_at(display_index)
      end

    end
  end
end
