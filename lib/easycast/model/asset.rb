require 'securerandom'
module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  # or an image timed gallery (slideshow)
  #
  class Asset

    def self.for(path)
      case path
      when /.html$/  then Asset::Html.new(path)
      when /.svg$/   then Asset::Svg.new(path)
      when /.png$/   then Asset::Png.new(path)
      when /.jpe?g$/ then Asset::Jpg.new(path)
      when /.mp4$/   then Asset::Mp4.new(path)
      when /.webm$/  then Asset::Webm.new(path)
      when /.ogg$/   then Asset::Ogg.new(path)
      when Hash
        case path[:type]
        when 'gallery' then Asset::Gallery.new(path)
        when 'layers'  then Asset::Layers.new(path)
        else raise ArgumentError, "Unknown type `#{path[:type]}`"
        end
      else
        raise ArgumentError, "Unrecognized asset type `#{path}`"
      end
    end

    def all_resources
      []
    end

    def to_html
      raise NotImplementedError
    end

    class SimpleFile < Asset

      def initialize(arg)
        @path = arg
        raise ConfigError, "Missing file `#{arg}`" unless file.exists?
      end
      attr_reader :path

      def file
        SCENES_FOLDER/"assets"/@path
      end

      def file_contents
        file.read
      end

      def ensure!
        raise ConfigError, "No such file `#{file}`" unless file.exists?
      end

    end

    class Html < SimpleFile

      def to_html
        "<article>" + file_contents + "</article>"
      end

    end # class Html

    class Svg < SimpleFile

      def to_html
        file_contents
      end

    end # class Svg

    class Png < SimpleFile

      def to_html
        %Q{<img src="/#{@path}">}
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

    end # class Png

    class Jpg < SimpleFile

      def to_html
        %Q{<img src="/#{@path}">}
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

    end # class Jpg

    class Mp4 < SimpleFile

      def to_html
        %Q{<video playsinline autoplay muted loop source src="/#{@path}" type="video/mp4">This browser does not support the video tag.</video>}
      end

      def all_resources
        []
      end

    end # class Mp4

    class Webm < SimpleFile

      def to_html
        %Q{<video preload autoplay src="/#{@path}" type="video/webm">This browser does not support the video tag.</video>}
      end

      def all_resources
        []
      end

    end # class Webm

    class Ogg < SimpleFile

      def to_html
        %Q{<video preload autoplay src="/#{@path}" type="video/ogg">This browser does not support the video tag.</video>}
      end

      def all_resources
        []
      end

    end # class Ogg

    class CompoundAsset < Asset

      def ensure!
        @assets.each do |a|
          a.ensure!
        end
      end

    end # class CompoundAsset

    class Gallery < CompoundAsset

      def initialize(arg)
        @id = SecureRandom.uuid
        @options = arg[:options] || { interval: 2 }
        @assets  = arg[:images].map { |i| Asset.for(i) }
        @target = SCENES_FOLDER/("assets/galleries")
      end

      def ensure!
        super
        generate_images!
      end

      def all_resources
        @generated.map{|a| { path: a, as: "image" } }
      end

      def to_html
        interval = @options[:interval] * 1000
        <<-HTML
<div id="#{@id}" class="gallery">
  <img />
  <script>jQuery(function(){ installGallery("#{@id}", #{@generated.to_json}, #{interval}); });</script>
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
              %Q{convert -resize 1920x #{a.file} #{file}}
            ].each do |cmd|
              puts "#{cmd}"
              `#{cmd}`
            end
          end
          @generated << "/galleries/#{name}.#{a.file.ext}"
        end
      end

    end

    class Layers < CompoundAsset

      def initialize(arg)
        @options = arg[:options] || { }
        @assets  = arg[:images].map { |i| Asset.for(i) }
        @sha = Digest::SHA1.hexdigest(@assets.map{|a| a.path }.join('/'))
        @path = "layers/#{@sha}.png"
        @file = SCENES_FOLDER/("assets/#{@path}")
      end

      def ensure!
        super
        generate_layer!
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

      def to_html
        %Q{<img src="/#{@path}">}
      end

    private

      def generate_layer!
        return if @file.exists?
        @file.parent.mkdir_p unless @file.parent.exists?
        puts "Generating asset `#{@file}`"
        [
          %Q{convert #{@assets.map{|a| a.file}.join(' ')} -background none -flatten #{@file}},
          %Q{convert -resize 1920x #{@file} #{@file}}
        ].each do |cmd|
          puts "#{cmd}"
          `#{cmd}`
        end
      end

    end # class Layers

  end # class Asset
end # module Easycast
