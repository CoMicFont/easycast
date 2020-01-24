module Easycast
  module Views
    #
    # Remote view, providing the context to remote.mustache
    #
    class Doors < View

      def title
        "Doors | Easycast"
      end

      def body_class
        "doors"
      end

      def nodes
        config.nodes.map{|n|
          { name: n[:name],
            index: n[:index],
            css_class: "node-#{n[:index]}"  }
        }
      end

      def main_script
        "jQuery(function(){ refresh(#{state_json}, refreshDoors); });"
      end

    end
  end
end
