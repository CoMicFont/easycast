module Easycast
  class Asset
    class Gallery < Asset

      def initialize(cast, path, config)
        super(cast, path, config)
        @options = path[:options] || { interval: 2 }
        @assets  = path[:images].map { |i| Image.new(cast, i, config) }
      end

      def ensure!
        generate_images!
      end

      def all_resources
        @generated.map{|a| { path: a, as: "image" } }
      end

      def to_html(state, cast)
        interval = @options[:interval] * 1000
        <<~HTML
          <div id="#{unique_id}" class="gallery">
          <img />
          <script>jQuery(function(){ installGallery("#{unique_id}", #{@generated.to_json}, #{interval}); });</script>
          </div>
        HTML
      end

    private

      def generate_images!
        @generated = @assets.map do |a|
          a.ensure!
          a.external_path
        end
      end

    end # class Gallery
  end # class Asset
end # module Easycast
