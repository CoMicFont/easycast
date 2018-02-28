module Easycast
  module Views
    #
    # Main view for decorating a given page inside the main HTML5
    # layout
    #
    class Layout < View

      def initialize(page)
        @page = page
      end
      attr_reader :page

      def title
        page.title
      end

      def body_class
        page.body_class
      end

      def yield
        page.render
      end

    end
  end
end
