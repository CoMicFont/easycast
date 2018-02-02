module Easycast
  #
  # This class is the ruby live version of the content found in
  # `scenes.yml`.
  #
  class Config < OpenStruct

    SCHEMA = Finitio::DEFAULT_SYSTEM.parse <<-FIO
      AssetPath = String( s | s.size>0 )
      Cast = {
        display: Integer
        remote: Boolean
        assets: [AssetPath]
      }
      Scene = {
        id: String
        name: String
        cast: [Cast]
      }
      Node = {
        name: String
        children :? [Node]
      } | {
        scene: String
        children :? [Node]
      }
      {
        scenes: [Scene]
        nodes: [Node]
      }
    FIO

    #
    # Loads a Scenes instance from a given folder.
    #
    # @raises ScenesError if something goes wrong with the folder or its
    #         structure. 
    #
    def self.load(folder)
      raise ConfigError, "Scenes folder does not exist `#{folder}`" unless folder.directory?
      yml = folder/"scenes.yml"
      raise ConfigError, "Missing scenes index file `#{yml}`" unless yml.file?
      yml_data = yml.load
      new SCHEMA.dress(yml_data)
    rescue Finitio::Error => ex
      raise ConfigError, "Corrupted scenes index file\n#{ex.root_cause.message}"
    end

    #
    # Returns the index-th scene as a Scene object
    #
    def scene(index)
      Scene.new(scenes[index].merge(index: index))
    end

    #
    # Allows iterating over Scene instances.
    #
    def each
      return to_enum unless block_given?
      scenes.each_with_index do |s, i|
        yield(scene(i))
      end
    end

  end # class Config
end # module Easycast
