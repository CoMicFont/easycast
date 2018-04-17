module Easycast
  module Views
    #
    # Main view for partial display view
    #
    class Partial < View

      def initialize(page)
        @page = page
      end
      attr_reader :page

      def all_resources
        []
      end

      def yield
        page.render
      end

    end
  end
end
