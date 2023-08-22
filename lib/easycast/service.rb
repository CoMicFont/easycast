require_relative 'assets'
require_relative 'controller'
module Easycast
  Service = Rack::Builder.new do
    use Rack::Nocache
    use Rack::Static, {
      :urls => ["/assets", "/fonts", "/webassets"],
      :root => PUBLIC_FOLDER
    }
    use Assets
    run Controller
  end
end
