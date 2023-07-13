require 'colorize'
require 'optparse'

module Easycast
  class Configure

    DEFAULT_OPTIONS = {
      source: Path.backfind('[Gemfile]')/'config',
      target: Path('/'),
      command: nil,
      colorize: true,
      dry_run: true,
      real_paths: false,
      verbose: false,
    }

    def initialize(argv, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @configs = check_configs!(options_parser.parse!(argv))
    end

    def options_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: [sudo] configure [options] CONFIG..."

        opts.on("--diff", "Show a diff of what would be done") do
          @options[:command] = :diff
        end

        opts.on("--configure", "Do the actual configuration") do
          @options[:command] = :configure
        end

        opts.on("--no-color", "Don't use colors") do
          @options[:colorize] = false
        end

        opts.on("--[no-]dry-run", "Do not do anything real") do |v|
          @options[:dry_run] = v
        end

        opts.on("--[no-]real-paths", "Show real paths unless of simplified ones") do |v|
          @options[:real_paths] = v
        end

        opts.on("--[no-]verbose", "Show more information (files that do not change)") do |v|
          @options[:verbose] = v
        end

        opts.on("--target=FOLDER", "Target folder to configure (defaults to '/')") do |target|
          path = Path(target)
          if path.directory?
            @options[:target] = path
          else
            fail!("No such folder `#{path}`")
          end
        end
      end
    end

    def check_configs!(configs)
      configs.map{|c|
        folder = @options[:source]/c
        if !folder.directory?
          fail!("Unknown configuration `#{missing}`, config/#{missing} is not a folder")
        end
        folder
      }
    end

    def config_files
      files = {}
      @configs.each do |config|
        config.glob("**/*", File::FNM_DOTMATCH) do |source|
          next unless source.file?
          target = @options[:target]/(source.relative_to(config))
          files[target] = source
        end
      end
      files
    end

    def run(stdout = $stdout)
      cmd = @options[:command]
      if cmd.nil?
        fail!("--configure or --diff must be used")
      else
        send("do_#{cmd}", stdout)
      end
    end

    def do_diff(stdout = $stdout)
      config_files.each_pair do |target,source|
        header = highlight_color("## #{relative_to(target, @options[:target])}") << "\n"
        if target.exists?
          identical = target.read == source.read
          if identical && @options[:verbose]
            stdout << header
            stdout << detail_color('nothing to do') << "\n\n"
          elsif !identical
            stdout << header
            stdout << `diff -s --color=#{@options[:colorize] ? 'always' : 'never'} #{target} #{source}`.strip << "\n\n"
          end
        else
          stdout << header
          stdout << source.read << "\n"
        end
      end
    end

    def do_configure(stdout = $stdout)
      config_files.each_pair do |target, source|
        mkdir_p(target.parent, stdout)
        instantiate_file(source, target, stdout)
      end
    end

    def mkdir_p(folder, stdout)
      return if folder.directory?

      stdout << info_color("mkdir -p #{relative_to(folder, @options[:target])}") << "\n"
      unless @options[:dry_run]
        folder.mkdir_p
      end
    end

    def instantiate_file(source, target, stdout)
      return if target.exist? && source.read == target.read

      stdout << info_color("cp #{relative_to(source, @options[:source])} #{relative_to(target, @options[:target])}") << "\n"
      unless @options[:dry_run]
        source.cp(target)
      end
    end

  ###

    def relative_to(x, origin)
      return x if @options[:real_paths]

      "/#{x.relative_to(origin)}"
    end

    def fail!(message)
      puts error_colored(message)
      exit(0)
    end

    def error_colored(str)
      return str unless @options[:colorize]

      str.red
    end

    def highlight_color(str)
      return str unless @options[:colorize]

      str.cyan
    end

    def detail_color(str)
      return str unless @options[:colorize]

      str.gray
    end

    def info_color(str)
      str
    end

  end # class Configure
end # module Easycast
