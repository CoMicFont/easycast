module Easycast
  class Asset
    class SimpleFile < Asset

      def file
        config.folder/"assets"/@path
      end

      def file_contents
        file.read
      end

      def ensure!
        raise ConfigError, "No such file `#{path}` (#{file})" unless file.exists?
      end

    end # class SimpleFile
  end # class Asset
end # module Easycast
