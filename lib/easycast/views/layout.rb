module Easycast
  module Views
    #
    # Main view for all pages, providing the global context for title
    # available scenes, current one, etc.
    #
    class Layout < Mustache

      def body_class
        @body_class
      end

      def title
        "Easycast | #{subtitle}"
      end

      def config
        @config
      end

      def displays
        (0..1).map do |index|
          {
            index: index,
            name: "Display #{index}"
          }
        end
      end

      #
      # nodes indexed by a search in depth
      #
      def nodes
        recursively_decorate_nodes([], config.nodes, 0)
      end

      private def recursively_decorate_nodes(acc, remaining_nodes, i)
        if remaining_nodes.empty? then acc
        else
          n, *tail = *remaining_nodes
          node = n.merge({
            index: i,
            name: (n[:name] ? n[:name] : config.scene_by_id(n[:scene])[:name]),
            active: (i == node_index),
            css_class: (i == node_index ? "active" : "")
          })
          children = node[:children] ? node[:children] : []
          recursively_decorate_nodes(acc + [node], children + tail, i+1)
        end
      end

      def node_index
        @node_index
      end

      def current_node
        config.node(node_index)
      end

      #
      # when current node has no scene field
      # the current scene is the first scene found by a search in depth
      # in the tree depicted by the current node
      #
      def current_scene
        scene_id = first_scene_id_in_depth([current_node])
        config.scene_by_id(scene_id)
      end

      #
      # Finds the first scene id encountered while traversing in depth
      # the tree depicted by the given node array.
      # Leaves must have a scene.
      # This is required for displaying a scene even if
      # the current node does not have one.
      #
      def first_scene_id_in_depth(nodes)
        if nodes.empty? then return nil
        else
          head, *tail = *nodes
          scene_id = head[:scene]
          if scene_id then return scene_id
          else
            first_scene_id_in_depth(head[:children] + tail)
          end
        end
      end

      def previous_index
        (node_index == 0 ? nodes.size : node_index) - 1
      end

      def previous_href
        "/node/#{previous_index}"
      end

      def next_index
        (node_index + 1) % nodes.size
      end

      def next_href
        "/node/#{next_index}"
      end

    end
  end
end
