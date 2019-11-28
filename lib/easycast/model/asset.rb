require 'securerandom'
module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  # or an image timed gallery (slideshow)
  #
  class Asset

    def self.for(path, config)
      case path
      when /.html$/  then Asset::Html.new(path, config)
      when /.svg$/   then Asset::Svg.new(path, config)
      when /.png$/   then Asset::Png.new(path, config)
      when /.jpe?g$/ then Asset::Jpg.new(path, config)
      when /.mp4$/   then Asset::Mp4.new(path, config)
      when /.webm$/  then Asset::Webm.new(path, config)
      when /.ogg$/   then Asset::Ogg.new(path, config)
      when Hash
        case path[:type]
        when 'gallery' then Asset::Gallery.new(path, config)
        when 'layers'  then Asset::Layers.new(path, config)
        else raise ArgumentError, "Unknown type `#{path[:type]}`"
        end
      else
        raise ArgumentError, "Unrecognized asset type `#{path}`"
      end
    end

    def all_resources
      []
    end

    def to_html(state)
      raise NotImplementedError
    end

    class SimpleFile < Asset

      def initialize(path, config)
        @path = path
        @config = config
        ensure!
      end
      attr_reader :path, :config

      def file
        config.folder/"assets"/@path
      end

      def file_contents
        file.read
      end

      def ensure!
        raise ConfigError, "No such file `#{path}`" unless file.exists?
      end

    end

    class Html < SimpleFile

      def to_html(state)
        "<article>" + file_contents + "</article>"
      end

    end # class Html

    class Svg < SimpleFile

      def to_html(state)
        file_contents
      end

    end # class Svg

    class Png < SimpleFile

      def to_html(state)
        %Q{<img src="/#{@path}">}
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

    end # class Png

    class Jpg < SimpleFile

      def to_html(state)
        %Q{<img src="/#{@path}">}
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

    end # class Jpg

    class Video < SimpleFile

      def to_html(state)
        video_options = config.videos
        mode = state.scheduler.paused? ? :pause : :play
        loop = !!video_options[:loop][mode] ? "loop" : ""
        %Q{<video playsinline autoplay muted #{loop} source style="height: 100%" src="/#{@path}" type="#{video_type}">This browser does not support the video tag.</video>}
      end

      def all_resources
        []
      end

    end

    class Mp4 < Video

      def video_type
        "video/mp4"
      end

    end # class Mp4

    class Webm < Video

      def video_type
        "video/webm"
      end

    end # class Webm

    class Ogg < Video

      def video_type
        "video/ogg"
      end

    end # class Ogg

    class CompoundAsset < Asset

      def initialize(config)
        @config = config
      end
      attr_reader :config

      def ensure!
        @assets.each do |a|
          a.ensure!
        end
      end

    end # class CompoundAsset

    class Gallery < CompoundAsset

      def initialize(arg, config)
        super(config)
        @id = SecureRandom.uuid
        @options = arg[:options] || { interval: 2 }
        @assets  = arg[:images].map { |i| Asset.for(i, config) }
        @target = config.folder/"assets/galleries"
      end

      def ensure!
        super
        generate_images!
      end

      def all_resources
        @generated.map{|a| { path: a, as: "image" } }
      end

      def to_html(state)
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

      def initialize(arg, config)
        super(config)
        @options = arg[:options] || { }
        @assets  = arg[:images].map { |i| Asset.for(i, config) }
        @sha = Digest::SHA1.hexdigest(@assets.map{|a| a.path }.join('/'))
        @path = "layers/#{@sha}.png"
        @file = config.folder/("assets/#{@path}")
      end

      def ensure!
        super
        generate_layer!
      end

      def all_resources
        [ { path: "/#{@path}", as: "image" } ]
      end

      def to_html(state)
        %Q{<img src="/#{@path}">}
      end

    private

      def generate_layer!
        return if @file.exists?
        @file.parent.mkdir_p unless @file.parent.exists?
        puts "Generating asset `#{@file}`"
        Path("/tmp/easycast").mkdir_p
        sources = @assets.map{|a|
          source = "/tmp/easycast/#{a.file.basename}"
          cmd = %Q{convert -resize 1920x #{a.file} #{source}}
          puts "#{cmd}"
          `#{cmd}`
          source
        }
        [
          %Q{convert #{sources.join(' ')} -background none -flatten #{@file}},
          %Q{convert -resize 1920x #{@file} #{@file}}
        ].each do |cmd|
          puts "#{cmd}"
          `#{cmd}`
        end
      end

    end # class Layers

  end # class Asset
end # module Easycast
