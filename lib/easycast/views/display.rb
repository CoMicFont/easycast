module Easycast
  module Views
    #
    # Display view, providing the context to display.mustache
    #
    class Display < View

      def initialize(config, state, display_index)
        super(config, state)
        @display_index = display_index
      end
      attr_reader :display_index

      def all_resources
        display_cast.all_resources
      end

      def title
        "Display #{display_index} | Easycast"
      end

      def with_remote
        display_cast[:remote]
      end

      def scene_id
        "scene-#{current_scene.id}"
      end

      def body_class
        with_remote ? "with-remote" : "without-remote"
        "display display-#{display_index} #{with_remote}"
      end

      def remote
        Remote::Floor.new(config, state, config.nodes).render
      end

      def display_cast
        @display_cast ||= current_scene.cast_at(display_index)
      end

      def assets
        @assets ||= display_cast.assets.map{|a|
          { to_html: a.to_html(state, display_cast) }
        }
      end

      def current_scene
        walk.current_scene
      end

      def main_script
        "jQuery(function(){ refresh(#{state_json}, refreshDisplay); });"
      end

    end
  end
end
