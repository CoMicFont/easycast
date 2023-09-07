module Easycast
  class Asset
    class Gallery < Compound

      def initialize(path, config)
        super(path, config)
        @options = path[:options] || { interval: 2 }
        @assets  = path[:images].map { |i| Image.new(i, config) }
        @target = config.folder/"assets/_galleries"
      end

      def ensure!
        super
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
        @target.mkdir_p unless @target.exists?
        @generated = []
        @assets.each do |a|
          name = Digest::SHA1.hexdigest(a.path)
          file = (@target/name).sub_ext(a.file.ext)
          unless file.exists?
            puts "Generating gallery image for `#{a.path}`"
            [
              convert(a.file, file)
            ].each do |cmd|
              puts "#{cmd}"
              `#{cmd}`
            end
          end
          @generated << "#{ASSETS_PREFIX}/_galleries/#{name}#{a.file.ext}"
        end
      end

    end # class Gallery
  end # class Asset
end # module Easycast
