module Easycast
  module Views
    #
    # Home view, providing the menu to choose a display to show
    #
    class Home < View

      def title
        "Home page | Easycast"
      end

      def body_class
        "home"
      end

      def displays
        (0..1).map do |index|
          {
            index: index,
            name: "Display #{index}"
          }
        end
      end

    end # class Home
  end # module Home
end # module Easycast
