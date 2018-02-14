require 'spec_helper'
module Easycast
  describe Config do

    let(:config) {
      Config.dress({
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
      })
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

    end

  end
end

