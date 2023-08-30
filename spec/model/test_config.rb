require 'spec_helper'
module Easycast
  describe Config do

    let(:config_data) {
      {
        scenes: [
          {
            id: "intro1",
            name: "Intro 1",
            cast: []
          },
          {
            id: "intro2",
            name: "Intro 2",
            cast: []
          },
          {
            id: "chapter1",
            name: "Chapter 1",
            cast: []
          },
          {
            id: "chapter1.section1",
            name: "Chapter 1, Section 1",
            cast: []
          }
        ],
        nodes: [
          {
            name: "Introduction",
            children: [
              {
                scene: "intro1"
              },
              {
                scene: "intro2"
              }
            ]
          },
          {
            scene: "chapter1",
            children: [
              {
                scene: "chapter1.section1"
              }
            ]
          },
        ]
      }
    }

    let(:config) {
      Config.dress(config_data)
    }

    describe "new" do

      it "puts a unique index on each node, corresponding to the node index in a DFS walk" do
        check = Proc.new{|n|
          expect(n[:index] >= 0)
          n[:children].each{|c|
            check.call(c)
          } if n[:children]
        }
        config.nodes.each do |n|
          check.call(n)
        end
      end

      it 'provides a default animation frequency if missing' do
        expect(config.animation).to eql({
          frequency: "45s",
          autoplay: true
        })
      end

      it 'uses the animation frequency, if any' do
        config = Config.dress(config_data.merge({
          "animation" => {
            "frequency" => "60s",
            "autoplay" => false
          }
        }))
        expect(config.animation).to eql({frequency: "60s", autoplay: false})
      end

      it 'has default options for videos' do
        config = Config.dress(config_data)
        expect(config.videos).to eql({loop: { play: false, pause: true }})
      end

    end

    describe "Change control" do

      let(:config){ Config.load(Path.dir.parent/"fixtures") }

      it 'works as expected' do
        expect(config.outdated?).to eql(false)
        (Path.dir.parent/"fixtures/scenes.yml").touch
        expect(config.outdated?).to eql(true)
      end

    end

  end
end
