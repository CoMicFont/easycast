require 'spec_helper'
module Easycast
  describe Controller do
    include Rack::Test::Methods

    def app
      Easycast::Controller
    end

    describe "GET /assets/..." do

      it 'serves the assets without trouble' do
        get '/assets/easycast.css'
        expect(last_response.status).to eql(200)
        get '/assets/easycast.js'
        expect(last_response.status).to eql(200)
      end

      it 'serves the vendor assets without trouble' do
        get '/assets/vendor.css'
        expect(last_response.status).to eql(200)
        get '/assets/vendor.js'
        expect(last_response.status).to eql(200)
      end

    end

    describe "GET /display/:i" do

      it 'serves the scene page without trouble' do
        get '/display/0'
        expect(last_response.status).to eql(200)
      end

    end

    describe "GET /remote" do

      it 'serves the scene page without trouble' do
        get '/remote'
        expect(last_response.status).to eql(200)
      end

    end

    describe 'GET /scene' do

      it 'returns the current scene' do
        get '/scene'
        expect(last_response.status).to eql(200)
      end

    end

    describe "POST /scene/i" do

      it 'lets specify the current scene' do
        post '/scene/1'
        expect(last_response.status).to eql(204)
      end

    end

  end
end
