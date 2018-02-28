module Easycast
  Service = Rack::Builder.new do
    use Rack::Nocache
    use Assets
    run Controller
  end
end
