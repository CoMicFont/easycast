require 'spec_helper'
module Easycast
  describe Controller do
    include Rack::Test::Methods

    def app
      Easycast::Controller
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

      it 'does not version the assets by default' do
        get subject
        expect(last_response.body).to match(/easycast(-\d+\.\d+\.\d+)?(.min)?.css/)
      end
    end

    describe "GET /splash" do
      subject { "/splash" }

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

    describe "GET /doors" do
      subject { "/doors" }
      it_behaves_like 'An end-user page'
    end

    describe 'GET /state' do

      it 'returns the current controller state' do
        get '/state'
        expect(last_response.status).to eql(200)
        expect(last_response.content_type).to eql("application/json")
      end

    end

    describe '/tour/...' do

      it 'POST lets specify the current node index' do
        post '/tour/jump/1'
        expect(last_response.status).to eql(204)
      end

      it 'POST lets start a sub tour on a node' do
        post '/tour/subtour/0'
        expect(last_response.status).to eql(204)
      end

      it 'POST next moves to the next node' do
        post '/tour/next'
        expect(last_response.status).to eql(204)
      end

      it 'POST previous moves to the previous node' do
        post '/tour/previous'
        expect(last_response.status).to eql(204)
      end

    end

    describe '/scheduler/...' do

      it 'allows pausing' do
        post '/scheduler/pause'
        expect(last_response.status).to eql(204)
      end

      it 'allows resuming' do
        post '/scheduler/resume'
        expect(last_response.status).to eql(204)
      end

      it 'allows toggling' do
        post '/scheduler/pause'
        post '/scheduler/toggle'
        expect(last_response.status).to eql(201)
        post '/scheduler/toggle'
        expect(last_response.status).to eql(204)
      end

    end

    describe "GET /display/:i in partial mode" do

      it 'returns the display body only' do
        header('Accept', "application/vnd.easycast.display+html")
        get '/display/0'
        expect(last_response).not_to match(/<body/)
      end

    end

  end
end
