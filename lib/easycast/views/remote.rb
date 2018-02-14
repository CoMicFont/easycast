module Easycast
  module Views
    #
    # Remote view, providing the context to remote.mustache
    #
    class Remote < View

      def initialize(config, walk)
        super(config)
        @walk = walk
      end
      attr_reader :walk

      def title
        "Remote | Easycast"
      end

      def body_class
        "remote"
      end

      def tree
        Remote::Floor.new(config, config.nodes, walk).render
      end

      def previous_href
        "/walk/previous"
      end

      def next_href
        "/walk/next"
      end

    end
  end
end
require_relative 'remote/floor'
require_relative 'remote/node'
