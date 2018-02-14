module Easycast
  module Views
    #
    # Display view, providing the context to display.mustache
    #
    class Display < View

      def initialize(config, display_index, walk)
        super(config)
        @display_index = display_index
        @walk = walk
      end
      attr_reader :display_index, :walk

      def title
        "Display #{display_index} | Easycast"
      end

      def with_remote
        display_cast[:remote]
      end

      def body_class
        with_remote ? "display with-remote" : "display without-remote"
      end

      def remote
        Remote::Floor.new(config, config.nodes, walk).render
      end

      def display_cast
        @display_cast ||= current_scene.cast_at(display_index)
      end

      def current_scene
        walk.current_scene
      end

    end
  end
end
