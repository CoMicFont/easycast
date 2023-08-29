module Easycast
  module Views
    class SplashLayout < View

      def initialize(page)
        @page = page
      end
      attr_reader :page

      def yield
        page.render
      end

      def splash_script
        Easycast::SprocketsAssets['easycast/splash.js']
      end

      def splash_style
        Easycast::SprocketsAssets['easycast/splash.css']
      end

      def main_script
        "splashConnect();"
      end

    end
  end
end
