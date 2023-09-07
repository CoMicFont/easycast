require 'securerandom'
module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  # or an image timed gallery (slideshow)
  #
  class Asset

    ASSETS_PREFIX = "/assets"

    def initialize(path, config)
      @path = path
      @config = config
    end
    attr_reader :path, :config

    def unique_id
      @unique_id ||= SecureRandom.uuid
    end

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

    def to_html(state, cast)
      raise NotImplementedError
    end

    def convert(source, target)
      %Q{convert -resize "1920x1080\>" #{source} #{target}}
    end

  end # class Asset
end # module Easycast
require_relative 'asset/simple_file'
require_relative 'asset/compound'

require_relative 'asset/html'
require_relative 'asset/svg'
require_relative 'asset/image'
require_relative 'asset/video'
require_relative 'asset/gallery'
require_relative 'asset/layers'
