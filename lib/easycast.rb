ENV['TZ'] = "Europe/Brussels"

require 'path'
require 'finitio'
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'mustache'
require 'rufus/scheduler'
require 'digest'
module Easycast

  # Version of Easycast software
  VERSION = "1.8.0"

  # Where easycast (the user) home folder is
  EASYCAST_USER_HOME = ENV['EASYCAST_USER_HOME'] || Dir.home

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  # Logger used everywhere for debugging and info
  LOGGER = Logger.new(STDOUT)

  # Main scenes folder
  SCENES_FOLDER = if folder = ENV['EASYCAST_SCENES_FOLDER']
    Path(folder)
  elsif (folder = ROOT_FOLDER/("scenes")).directory?
    folder
  else
    ROOT_FOLDER/("documentation")
  end

  # Public assets folder
  PUBLIC_FOLDER = ROOT_FOLDER/('public')

  # Public assets folder
  WEBASSETS_FOLDER = ROOT_FOLDER/('public/webassets')

  # Let mustache know where its templates are
  Mustache.template_path = ROOT_FOLDER/("lib")

  # Whether we want sinatra to reload everytime
  DEVELOPMENT_MODE = (ENV['RACK_ENV'].to_s =~ /^devel/i)

end
require_relative 'easycast/error'
require_relative 'easycast/model/config'
require_relative 'easycast/model/scene'
require_relative 'easycast/model/station'
require_relative 'easycast/model/cast'
require_relative 'easycast/model/asset'
require_relative 'easycast/model/walk'
require_relative 'easycast/model/tour'
require_relative 'easycast/configure'
