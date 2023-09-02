require 'colorize'
require 'optparse'
require 'mustache'
require 'open-uri'
require 'yaml'

module Easycast
  class Configure

    DEFAULT_OPTIONS = {
      source: Path.backfind('[Gemfile]')/'config',
      target: Path('/'),
      scenes_folder: SCENES_FOLDER,
      command: nil,
      station: nil,
      colorize: true,
      dry_run: true,
      real_paths: false,
      verbose: false,
      post_install: true,
    }

    def initialize(argv, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @roles = check_roles!(options_parser.parse!(argv))
    end

    def options_parser
      @options_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: [sudo] configure [options] CONFIG..."

        opts.on("-j", "--jelp", "Print this help") do |v|
          puts opts
          fail!("")
        end

        opts.on("--diff=[STATION]", "Show a diff of what would be done") do |station|
          @options[:command] = :diff
          @options[:station] = station
        end

        opts.on("--configure=[STATION]", "Do the actual configuration") do |station|
          @options[:command] = :configure
          @options[:station] = station
        end

        opts.on("--station=URI", "Specify the station configuration to us") do |uri|
          data = YAML.load(URI.open(uri).read)
          @station_config = Station.dress(data)
        end

        opts.on("--no-color", "Don't use colors") do
          @options[:colorize] = false
        end

        opts.on("--[no-]post-install", "Do not run post-install script") do |v|
          @options[:post_install] = v
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

    def check_roles!(roles)
      roles = station_roles if roles.empty?
      if roles.empty?
        puts options_parser
        fail!("A list of roles must be provided when a station is not specified")
      end

      roles.map{|role|
        folder = @options[:source]/role
        if !folder.directory?
          fail!("Unknown role `#{role}`, config/#{folder} is not a folder")
        end
        folder
      }
    end

    def config_files
      files = {}
      @roles.each do |config|
        config.glob("**/*", File::FNM_DOTMATCH) do |source|
          next unless source.file?
          next if source.basename.to_s == "postinstall.sh"

          target = @options[:target]/(source.relative_to(config))
          target = target.rm_ext if source.ext == ".tpl"
          target = instantiate_file_path(target)
          files[target] = source
        end
      end
      files
    end

    def run(stdout = $stdout)
      cmd = @options[:command]
      if cmd.nil?
        puts options_parser
        fail!("--configure or --diff must be used")
      else
        send("do_#{cmd}", stdout)
      end
    end

    def do_diff(stdout = $stdout)
      config_files.each_pair do |target,source|
        header = highlight_color("## #{relative_to(target, @options[:target])}") << "\n"
        if target.exists?
          source_content, is_template = instantiated_content(source)
          identical = (target.read == source_content)
          if identical && @options[:verbose]
            stdout << header
            stdout << detail_color('nothing to do') << "\n\n"
          elsif !identical
            stdout << header
            stdout << `diff -s --color=#{@options[:colorize] ? 'always' : 'never'} #{source} #{target}`.strip << "\n\n"
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
      do_post_install(stdout) if @options[:post_install]
    end

    def mkdir_p(folder, stdout)
      return if folder.directory?

      stdout << info_color("mkdir -p #{relative_to(folder, @options[:target])}") << "\n"
      unless @options[:dry_run]
        folder.mkdir_p
      end
    end

    def instantiate_file(source, target, stdout)
      source_content, is_template = instantiated_content(source)
      target_content = target.exist? ? target.read : nil
      return if source_content == target_content

      command = is_template ? "mustache" : "cp"
      stdout << info_color("#{command} #{relative_to(source, @options[:source])} #{relative_to(target, @options[:target])}") << "\n"
      unless @options[:dry_run]
        target.write(source_content)
      end
    end

    def do_post_install(stdout = $stdout)
      @roles.each do |cfg|
        next unless (script = cfg/"postinstall.sh").file?

        if @options[:dry_run]
          stdout << highlight_color("Would run #{script}") << "\n"
        else
          if Kernel.system(script.to_s, @options[:target].to_s)
            stdout << highlight_color("#{script} ran") << "\n"
          else
            fail!("#{script} failed.")
          end
        end
      end
    end

  ###

    def relative_to(x, origin)
      return x if @options[:real_paths]

      "/#{x.relative_to(origin)}"
    end

    def instantiate_file_path(path, scope = nil)
      return path unless path.to_s =~ /\$\{[^\}]+\}/

      scope ||= mustache_data
      s = path.to_s.gsub(/\$\{[^\}]+\}/) do |var|
        scope.instance_eval(var[2...-1])
      end
      Path(s)
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

    def instantiated_content(source)
      is_template = source.ext == ".tpl"
      if is_template
        [Mustache.render(source.read, mustache_data), true]
      else
        [source.read, false]
      end
    end

    def mustache_data
      OpenStruct.new({
        station_config: station_config!,
      })
    end

    def station_roles
      station_config!.roles
    end

    def station_config!
      @station_config ||= begin
        unless s = @options[:station]
          fail!("A station must be specified when instantiating templates")
        end
        station_config = scene_config!.station_by_name(s)
        unless station_config
          names = scene_config!.each_station.map{|s| s[:name] }.join(",")
          fail!("Unknown station #{s} (known: #{names})")
        end
        station_config
      end
    end

    def scene_config!
      @scene_config ||= begin
        unless cfg = @options[:scenes_folder]
          fail!("A scenes folder must be provided to instantiate config templates")
        end
        unless cfg.directory? && (cfg/"scenes.yml").file?
          fail!("#{cfg}/scenes.yml does not exist")
        end
        Config.load(cfg)
      end
    end

  end # class Configure
end # module Easycast
