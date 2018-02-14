require 'spec_helper'
module Easycast
  describe Walk do

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

    let(:walk) {
      Walk.new(config)
    }

    describe "current_scene" do

      it 'initially returns the scene of the first scened node' do
        expect(walk.current_scene.name).to eql("Intro 1")
      end

    end

    describe "next" do

      it 'returns another walk' do
        expect(walk.next).to be_a(Walk)
      end

      it 'does not touch the original one' do
        successor = walk.next
        expect(walk.current_scene.name).to eql("Intro 1")
      end

      it 'sets the new walk on the next scene' do
        expect(walk.next.current_scene.name).to eql("Intro 2")
      end

      it 'stops on non leaf having scenes' do
        expect(walk.next.next.current_scene.name).to eql("Chapter 1")
      end

      it 'deeply enters sections' do
        expect(walk.next.next.next.current_scene.name).to eql("Chapter 1, Section 1")
      end

      it 'loops back to the first scene' do
        expect(walk.next.next.next.next.current_scene.name).to eql("Intro 1")
      end

    end

    describe "previous" do

      it 'returns another walk' do
        expect(walk.previous).to be_a(Walk)
      end

      it 'does not touch the original one' do
        successor = walk.previous
        expect(walk.current_scene.name).to eql("Intro 1")
      end

      it 'sets the new walk on the previous scene' do
        expect(walk.previous.current_scene.name).to eql("Chapter 1, Section 1")
      end

      it 'stops on non leaf having scenes' do
        expect(walk.previous.previous.current_scene.name).to eql("Chapter 1")
      end

      it 'deeply enters sections' do
        expect(walk.previous.previous.previous.current_scene.name).to eql("Intro 2")
      end

      it 'loops back to the first scene' do
        expect(walk.previous.previous.previous.previous.current_scene.name).to eql("Intro 1")
      end

    end

    describe "jump" do

      it 'returns another walk' do
        expect(walk.jump(2)).to be_a(Walk)
      end

      it 'does not touch the original one' do
        successor = walk.jump(2)
        expect(walk.current_scene.name).to eql("Intro 1")
      end

      it 'Moves to the n-th node in the linearization' do
        expect(walk.jump(2).current_scene.name).to eql("Intro 2")
        expect(walk.jump(3).current_scene.name).to eql("Chapter 1")
      end

      it 'Skips unscened nodes' do
        expect(walk.jump(0).current_scene.name).to eql("Intro 1")
      end

      it 'Applies % n, and is thus robust' do
        expect(walk.jump(10).current_scene.name).to eql("Intro 1")
      end

    end

  end
end

