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
                scene: "intro2",
                repeat: 2
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

    describe "is_at_begin?" do

      it "returns true at beginning" do
        expect(walk.is_at_begin?).to eql(true)
      end

      it "returns false after next" do
        expect(walk.next.is_at_begin?).to eql(false)
      end

      it "returns false after previous (on the example at least)" do
        expect(walk.previous.is_at_begin?).to eql(false)
      end
    end

    describe "is_at_end?" do

      it "returns false at beginning" do
        expect(walk.is_at_end?).to eql(false)
      end

      it "returns false after next (on the example at least)" do
        expect(walk.next.is_at_end?).to eql(false)
      end

      it "returns true after previous" do
        expect(walk.previous.is_at_end?).to eql(true)
      end
    end

    describe 'home' do

      it 'returns another walk' do
        expect(walk.home).to be_a(Walk)
      end

      it 'goes to home' do
        home = walk.next.next.home
        expect(home.current_scene.name).to eql("Intro 1")
      end

    end

    describe "manual next" do

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

    describe "auto next" do

      it 'returns another walk' do
        expect(walk.next(true)).to be_a(Walk)
      end

      it 'does not touch the original one' do
        successor = walk.next(true)
        expect(walk.current_scene.name).to eql("Intro 1")
      end

      it 'sets the new walk on the next scene when no repeat is specified' do
        expect(walk.next(true).current_scene.name).to eql("Intro 2")
      end

      it 'sets the new walk on the current scene when a repeat is specified' do
        expect(walk.next(true).next(true).current_scene.name).to eql("Intro 2")
      end

      it 'sets the new walk on the next scene when the repeat is exhausted' do
        expect(walk.next(true).next(true).next(true).current_scene.name).to eql("Chapter 1")
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

      it 'initializes correctly the repeat number of a target scene that must not be repeated' do
        expect(walk.previous.next(true).current_scene.name).to eql("Intro 1")
      end

      it 'initializes correctly the repeat number of a target scene that must be repeated' do
        scene_with_repeat = walk.previous.previous.previous
        expect(scene_with_repeat.next(true).current_scene.name).to eql("Intro 2")
        expect(scene_with_repeat.next(true).next(true).current_scene.name).to eql("Chapter 1")
      end

      it 'initializes correctly the repeat number of a target scene that must not be repeated even if it went through a repeat scene' do
        scene_with_repeat = walk.previous.previous.previous
        expect(scene_with_repeat.previous.current_scene.name).to eql("Intro 1")
        expect(scene_with_repeat.previous.next(true).current_scene.name).to eql("Intro 2")
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

      it 'initializes correctly the repeat number of a target scene that must not be repeated' do
        expect(walk.jump(1).next(true).current_scene.name).to eql("Intro 2")
      end

      it 'initializes correctly the repeat number of a target scene that must be repeated' do
        scene_with_repeat = walk.jump(2)
        expect(scene_with_repeat.next(true).current_scene.name).to eql("Intro 2")
        expect(scene_with_repeat.next(true).next(true).current_scene.name).to eql("Chapter 1")
      end

      it 'initializes correctly the repeat number of a target scene that must not be repeated even if it went through a repeat scene' do
        scene_with_repeat = walk.jump(2)
        expect(scene_with_repeat.jump(3).current_scene.name).to eql("Chapter 1")
        expect(scene_with_repeat.jump(3).next(true).current_scene.name).to eql("Chapter 1, Section 1")
      end

    end

  end
end
