module Easycast
  module Views
    #
    # Remote view, providing the context to remote.mustache
    #
    class Remote < View

      def title
        "Remote | Easycast"
      end

      def body_class
        "remote"
      end

      def tree
        Remote::Floor.new(config, state, config.nodes).render
      end

      def previous_href
        "/tour/previous"
      end

      def next_href
        "/tour/next"
      end

      def scheduler_toggle_href
        "/scheduler/toggle"
      end

      def scheduler_icon
        state.scheduler.paused? ? "play" : "pause"
      end

      def main_script
        "jQuery(function(){ refresh(#{state_json}, refreshRemote); });"
      end

    end
  end
end
require_relative 'remote/floor'
require_relative 'remote/node'
