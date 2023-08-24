require 'spec_helper'
module Easycast
  describe Configure do

    class Configure
      def fail!(msg)
        raise msg
      end
    end

    let(:fixtures) do
      Path.dir/"fixtures"/"configure"
    end

    let(:target) do
      Path.dir/"fixtures"/"target"
    end

    describe "build_tree" do
      let(:configure) do
        Configure.new(["base", "master"], source: fixtures)
      end

      subject do
        configure.config_files
      end

      it 'works as expected' do
        expect(subject).to eql({
          Path("/etc/a_file.conf") => fixtures/"master"/"etc"/"a_file.conf"
        })
      end
    end

    describe "--diff" do
      let(:configure) do
        Configure.new(["--diff", "--no-color", "base", "master"], source: fixtures)
      end

      let(:stdout) do
        StringIO.new
      end

      subject do
        configure.run(stdout)
      end

      it 'works as expected' do
        subject
        expect(stdout.string).to eql(<<~OUT)
        ## /etc/a_file.conf
        master one

        OUT
      end
    end

    describe "--configure" do
      let(:configure) do
        Configure.new(["--configure", "--no-dry-run", "--no-color", "base", "master"], source: fixtures, target: target/"empty")
      end

      before(:each) do
        (target/"empty").rm_rf
        (target/"empty").mkdir_p
      end

      after(:each) do
        (target/"empty").rm_rf
        (target/"empty").mkdir_p
      end

      let(:stdout) do
        StringIO.new
      end

      subject do
        configure.run(stdout)
      end

      it 'works as expected' do
        subject
        expect(stdout.string).to eql(<<~OUT)
        mkdir -p /etc
        cp /master/etc/a_file.conf /etc/a_file.conf
        OUT
        expect(target/"empty"/"etc"/"a_file.conf").to exist
        expect((target/"empty"/"etc"/"a_file.conf").read).to eql("master one\n")
      end
    end

    describe "--configure with templates" do
      let(:configure) do
        Configure.new(["--configure=slave", "--no-dry-run", "--no-color", "tpl"], {
          source: fixtures,
          target: target/"empty",
          scenes_folder: fixtures.parent,
        })
      end

      before(:each) do
        (target/"empty").rm_rf
        (target/"empty").mkdir_p
      end

      after(:each) do
        (target/"empty").rm_rf
        (target/"empty").mkdir_p
      end

      let(:stdout) do
        StringIO.new
      end

      subject do
        configure.run(stdout)
      end

      it 'works as expected' do
        subject
        expect(stdout.string).to eql(<<~OUT)
        mkdir -p /etc
        mustache /tpl/etc/a_file.conf.tpl /etc/a_file.conf
        OUT
        expect(target/"empty"/"etc"/"a_file.conf").to exist
        expect((target/"empty"/"etc"/"a_file.conf").read).to eql("EASYCAST_DISPLAYS=1-1920,0\n")
      end
    end
  end
end
