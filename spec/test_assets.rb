require 'spec_helper'
module Easycast
  describe Assets do
    include Rack::Test::Methods

    def app
      Easycast::Assets
    end

    it 'serves the webassets without trouble' do
      get '/webassets/easycast.css'
      expect(last_response.status).to eql(200)
      get '/webassets/easycast.js'
      expect(last_response.status).to eql(200)
    end

    it 'serves the vendor webassets without trouble' do
      get '/webassets/vendor.css'
      expect(last_response.status).to eql(200)
      get '/webassets/vendor.js'
      expect(last_response.status).to eql(200)
    end

    it 'serves the fonts without trouble and allows caching' do
      get '/fonts/FontAwesome.otf'
      expect(last_response.status).to eql(200)
    end

  end
end
