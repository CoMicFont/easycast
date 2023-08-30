require 'spec_helper'
module Easycast
  describe Station do
    describe "dress" do
      let(:data) {
        {
          "name" => "master",
          "roles" => ["master", "station"],
          "displays" => [
            {
              "identifier" => 1,
              "size" => "2560x1440",
              "position" => "2560,0",
            },
          ],
        }
      }

      it 'works' do
        s = Station.dress(data)
        expect(s.name).to eql("master")
        expect(s.displays_envvar).to eql("1-2560,0-2560x1440")
      end
    end
  end
end
