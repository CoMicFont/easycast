ENV['TZ'] = "Europe/Brussels"

require 'path'
require 'fileutils'
require 'json'
require 'finitio'
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'mustache'
require 'rufus/scheduler'
require 'digest'
require 'securerandom'
module Easycast

  # Version of Easycast software
  VERSION = "1.9.4"

  # Where easycast (the user) home folder is
  EASYCAST_USER_HOME = ENV['EASYCAST_USER_HOME'] || Dir.home

  # The name of the user itself
  EASYCAST_USER = EASYCAST_USER_HOME.split('/').last

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  # Logger used everywhere for debugging and info
  LOGGER = Logger.new(STDOUT)

  # Where some sources can be found...
  SOURCES_FOLDERS = if ENV['EASYCAST_SOURCE_FOLDERS']
    ENV['EASYCAST_SOURCE_FOLDERS'].split(",").map { |p| Path(p) }
  else
    [ROOT_FOLDER]
  end

  # Public assets folder
  PUBLIC_FOLDER = ROOT_FOLDER/('public')

  # Public assets folder
  WEBASSETS_FOLDER = ROOT_FOLDER/('public/webassets')

  # Let mustache know where its templates are
  Mustache.template_path = ROOT_FOLDER/("lib")

  # Whether we want sinatra to reload everytime
  DEVELOPMENT_MODE = (ENV['RACK_ENV'].to_s =~ /^devel/i)

  def each_scenes_folder
    return to_enum(:each_scenes_folder) unless block_given?

    SOURCES_FOLDERS.each do |folder|
      folder.glob('**/scenes.yml').each {|scenes_file|
        yield scenes_file.parent
      }
    end
  end
  module_function :each_scenes_folder

  def current_scenes_folder
    path = ROOT_FOLDER/'scenes'
    set_current_scenes_folder(each_scenes_folder.first) unless path.exists?
    path
  end
  module_function :current_scenes_folder

  def set_current_scenes_folder(folder)
    target = (ROOT_FOLDER/'scenes')
    target.unlink if target.exists?
    FileUtils.ln_s folder.to_s, target.to_s, force: true
  end
  module_function :set_current_scenes_folder

end
require_relative 'easycast/error'
require_relative 'easycast/model/config'
require_relative 'easycast/model/scene'
require_relative 'easycast/model/conversion'
require_relative 'easycast/model/station'
require_relative 'easycast/model/cast'
require_relative 'easycast/model/asset'
require_relative 'easycast/model/walk'
require_relative 'easycast/model/tour'
require_relative 'easycast/configure'
