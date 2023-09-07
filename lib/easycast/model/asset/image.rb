module Easycast
  class Asset
    class Image < SimpleFile

      def initialize(path, config)
        super(path, config)
        @file = config.folder/"assets"/path
        @target = config.folder/"assets/_images"
        @name = Digest::SHA1.hexdigest(path)
        @external_path = "assets/_images/#{@name}#{@file.ext}"
        @target_image = (@target/@name).sub_ext(@file.ext)
      end

      def ensure!
        generate_image!
      end

      def file
        @file
      end

      def to_html(state, cast)
        %Q{<img src="/#{@external_path}">}
      end

      def all_resources
        [ { path: "/#{@external_path}", as: "image" } ]
      end

      private

        def generate_image!
          @target.mkdir_p unless @target.exists?
          unless @target_image.exists?
            puts "Generating image for `#{@external_path}`"
            cmd = convert(@file, @target_image)
            puts "#{cmd}"
            `#{cmd}`
          end
        end

    end

    class Png < Image
    end # class Png

    class Jpg < Image
    end # class Jpg
  end # class Asset
end # module Easycast
