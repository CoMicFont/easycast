module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  #
  class Asset

    def initialize(path)
      @path = path
    end

    def self.for(path)
      case path
      when /.html$/ then Asset::Html.new(path)
      when /.svg$/  then Asset::Svg.new(path)
      when /.png$/  then Asset::Png.new(path)
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

  end # class Asset
end # module Easycast
