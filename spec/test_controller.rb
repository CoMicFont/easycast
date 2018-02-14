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

    shared_examples_for "An end-user page" do

      it 'it served without trouble' do
        get subject
        expect(last_response.status).to eql(200)
      end

      it 'it uses the layout' do
        get subject
        expect(last_response.body).to match(/<html/)
      end

    end

    describe "GET /home" do
      subject { "/" }
      it_behaves_like 'An end-user page'
    end

    describe "GET /display/:i" do
      subject { "/display/0" }
      it_behaves_like 'An end-user page'
    end

    describe "GET /remote" do
      subject { "/remote" }
      it_behaves_like 'An end-user page'
    end

    describe '/walk/...' do

      it 'GET returns the current node index' do
        get '/walk/state'
        expect(last_response.status).to eql(200)
        expect(last_response.body).to match(/^\d+$/)
      end

      it 'POST lets specify the current node index' do
        post '/walk/state/1'
        expect(last_response.status).to eql(204)
      end

      it 'POST next moves to the next node' do
        post '/walk/next'
        expect(last_response.status).to eql(204)
      end

      it 'POST previous moves to the previous node' do
        post '/walk/previous'
        expect(last_response.status).to eql(204)
      end

    end

  end
end
