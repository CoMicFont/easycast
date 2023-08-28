require_relative 'controller'
require_relative 'cache_middleware'
module Easycast
  SprocketsAssets = Sprockets::Environment.new
  SprocketsAssets.append_path Path.dir/('webassets')
  SprocketsAssets.append_path SCENES_FOLDER/("assets")
  SprocketsAssets.css_compressor = :scss

  Service = Rack::Builder.new do
    use Rack::CommonLogger, LOGGER
    use CacheMiddleware
    use Rack::Static, {
      :urls => ["/assets", "/fonts", "/webassets"],
      :root => PUBLIC_FOLDER
    }
    map '/devassets' do
      run SprocketsAssets
    end if Easycast::DEVELOPMENT_MODE
    run Controller
  end
end
