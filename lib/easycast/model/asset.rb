module Easycast
  #
  # An Asset is some media that can be shown on a display, such
  # as an html file, an image, a video, etc.
  # or an image timed gallery (slideshow)
  #
  class Asset

    def initialize(cast, path, config)
      @cast = cast
      @path = path
      @config = config
    end
    attr_reader :cast, :path, :config

    def unique_id
      @unique_id ||= SecureRandom.uuid
    end

    def self.for(cast, path, config)
      case path
      when /.html$/  then Asset::Html.new(cast, path, config)
      when /.svg$/   then Asset::Svg.new(cast, path, config)
      when /.png$/   then Asset::Png.new(cast, path, config)
      when /.jpe?g$/ then Asset::Jpg.new(cast, path, config)
      when /.mp4$/   then Asset::Mp4.new(cast, path, config)
      when /.webm$/  then Asset::Webm.new(cast, path, config)
      when /.ogg$/   then Asset::Ogg.new(cast, path, config)
      when Hash
        case path[:type]
        when 'gallery' then Asset::Gallery.new(cast, path, config)
        when 'layers'  then Asset::Layers.new(cast, path, config)
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

    def conversion_names

    end

    def conversions
      conversion_names = config.display_by_num(cast.display)[:conversions] || []
      conversion_names.map {|name|
        config.conversion_by_name!(name).command
      }
    end

    def transformed_sha(data)
      Digest::SHA1.hexdigest(data.merge({
        conversions: conversions,
      }).to_json)
    end

    def convert(source, target)
      result = conversions.inject(source) do |src, command|
        Path.tempfile(['easycast', src.ext]).tap do |tmp|
          cmd = command.gsub(/\$source/, src.to_s).gsub(/\$target/, tmp.to_s)
          puts cmd
          `#{cmd}`
        end
      end
      result.mv(target)
    end

  end # class Asset
end # module Easycast
require_relative 'asset/simple_file'

require_relative 'asset/html'
require_relative 'asset/svg'
require_relative 'asset/image'
require_relative 'asset/video'
require_relative 'asset/gallery'
require_relative 'asset/layers'
