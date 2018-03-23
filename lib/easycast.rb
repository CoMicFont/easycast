require 'path'
require 'finitio'
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'mustache'
require 'rack/nocache'
require 'rufus/scheduler'
module Easycast

  # Version of Easycast software
  VERSION = "1.2.1"

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  # Logger used everywhere for debugging and info
  LOGGER = Logger.new(STDOUT)

  # Main scenes folder
  SCENES_FOLDER = if folder = ENV['EASYCAST_SCENES_FOLDER']
    folder
  elsif (folder = ROOT_FOLDER/("scenes")).directory?
    folder
  else
    ROOT_FOLDER/("documentation")
  end

  # Public assets folder
  WEBASSETS_FOLDER = SCENES_FOLDER/('assets/webassets')

  # Let mustache know where its templates are
  Mustache.template_path = ROOT_FOLDER/("lib")

  # Whether we want sinatra to reload everytime
  DEVELOPMENT_MODE = not(ENV['EASYCAST_DEVELOPMENT_MODE'].nil?)

end
require_relative 'easycast/error'
require_relative 'easycast/model/config'
require_relative 'easycast/model/scene'
require_relative 'easycast/model/cast'
require_relative 'easycast/model/asset'
require_relative 'easycast/model/walk'
require_relative 'easycast/controller'
require_relative 'easycast/assets'
require_relative 'easycast/service'
