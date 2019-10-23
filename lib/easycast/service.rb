require_relative 'assets'
require_relative 'controller'
module Easycast
  Service = Rack::Builder.new do
    use Rack::Nocache
    use Assets
    run Controller
  end
end
