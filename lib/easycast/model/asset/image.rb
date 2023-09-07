module Easycast
  class Asset
    class Image < SimpleFile

      def initialize(cast, path, config)
        super(cast, path, config)
        @file = config.folder/"assets"/path
        @target = config.folder/"assets/_images"
        @sha = transformed_sha({
          path: path
        })
        @external_path = "/assets/_images/#{@sha}#{@file.ext}"
        @target_image = (@target/@sha).sub_ext(@file.ext)
      end
      attr_reader :external_path, :target_image

      def ensure!
        generate_image!
      end

      def file
        @file
      end

      def to_html(state, cast)
        %Q{<img src="#{@external_path}">}
      end

      def all_resources
        [ { path: "#{@external_path}", as: "image" } ]
      end

      private

        def generate_image!
          return if @target_image.exists?

          @target.mkdir_p
          puts "\nGenerating image #{path} -> `#{@external_path}`"
          convert(@file, @target_image)
        end

    end

    class Png < Image
    end # class Png

    class Jpg < Image
    end # class Jpg
  end # class Asset
end # module Easycast
