require 'spec_helper'
module Easycast
  describe Service do
    include Rack::Test::Methods

    def app
      Easycast::Service
    end

    it 'serves the webassets without trouble' do
      get '/webassets/easycast.js'
      expect(last_response.status).to eql(200)
      expect(last_response).to allow_cache(['ETag'])
    end

    it 'serves the home page without trouble' do
      get '/'
      expect(last_response.status).to eql(200)
      expect(last_response.body).to match("<html")
      expect(last_response.body).to match(/easycast(-\d+\.\d+\.\d+)?.css/)
      expect(last_response).to disallow_cache
    end

    it 'serves a display page without trouble' do
      get "/display/0"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to match("<html")
      expect(last_response).to disallow_cache
    end

  end
end
