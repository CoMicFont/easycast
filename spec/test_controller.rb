require 'spec_helper'
module Easycast
  describe Controller do
    include Rack::Test::Methods

    def app
      Easycast::Controller
    end

    describe "GET /webassets/..." do

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

    describe 'GET /node' do

      it 'returns the current node' do
        get '/node'
        expect(last_response.status).to eql(200)
      end

    end

    describe "POST /node/i" do

      it 'lets specify the current node' do
        post '/node/1'
        expect(last_response.status).to eql(204)
      end

    end

  end
end
