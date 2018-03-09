require 'securerandom'
module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  # or an image timed gallery (slideshow)
  #
  class Asset

    def initialize(arg)
      if arg.is_a?(Hash)
        # this is a gallery asset
        @options = arg[:options] || { interval: 2 }
        @assets  = arg[:images].map { |i| Asset.for(i) }
      else
        # this is a path asset
        @path = arg
      end
    end

    def self.for(path)
      case path
      when /.html$/  then Asset::Html.new(path)
      when /.svg$/   then Asset::Svg.new(path)
      when /.png$/   then Asset::Png.new(path)
      when /.jpe?g$/ then Asset::Jpg.new(path)
      when /.mp4$/   then Asset::Mp4.new(path)
      when /.webm$/  then Asset::Webm.new(path)
      when /.ogg$/   then Asset::Ogg.new(path)
      else                Asset::Gallery.new(path)
      end
    end

    def file_contents
      (SCENES_FOLDER/"assets"/@path).read
    end

    def to_html
      raise NotImplementedError
    end

    class Html < Asset

      def to_html
        "<article>" + file_contents + "</article>"
      end

    end # class Html

    class Svg < Asset

      def to_html
        file_contents
      end

    end # class Svg

    class Png < Asset

      def to_html
        %Q{<img src="/#{@path}">}
      end

    end # class Png

    class Jpg < Asset

      def to_html
        %Q{<img src="/#{@path}">}
      end

    end # class Jpg

    class Mp4 < Asset

      def to_html
        %Q{<video autoplay>
  <source src="/#{@path}" type="video/mp4">
This browser does not support the video tag.
</video>}
      end

    end # class Mp4

    class Webm < Asset

      def to_html
        %Q{<video autoplay>
  <source src="/#{@path}" type="video/webm">
This browser does not support the video tag.
</video>}
      end

    end # class Webm

    class Ogg < Asset

      def to_html
        %Q{<video autoplay>
  <source src="/#{@path}" type="video/ogg">
This browser does not support the video tag.
</video>}
      end

    end # class Ogg

    class Gallery < Asset
      def initialize(arg)
        @id = SecureRandom.uuid
        super(arg)
      end
  
      def to_html
        interval = @options[:interval] * 1000
        <<-HTML
<div id="#{@id}" class="gallery">
  #{@assets.map { |a| a.to_html }.join("\n  ")}
  <script>installGallery("#{@id}", #{interval});</script>
</div>
HTML
      end

    end # class Gallery

  end # class Asset
end # module Easycast
