# encoding: UTF-8

require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sinatra'
require 'rack-flash'
require 'erb'
require 'json'
require 'sinatra/assetpack'
require 'sinatra/cache'

require 'webpage-archivist/migrations'
require_relative 'lib/migrations'
require 'webpage-archivist'
require_relative 'lib/models'

require_relative 'lib/countries'

require 'find'

WebpageArchivist::Snapshoter.height= 720
WebpageArchivist::Snapshoter.thumbnail_crop_height= 720

module NewsMemory

  ARCHIVIST = WebpageArchivist::WebpageArchivist.new

  PAGE_SIZE = 100

  class Server < Sinatra::Base

    set :root, File.dirname(__FILE__)
    set :views, File.dirname(__FILE__) + '/views'
    set :public, File.dirname(__FILE__) + '/public'

    use Rack::Session::Pool
    require 'rack/openid'
    use Rack::OpenID
    use Rack::Flash

    require_relative 'lib/helpers'
    helpers Sinatra::NewsMemoryHelper

    register Sinatra::AssetPack

    configure :development do
      WebpageArchivist::DATABASE.loggers << Logger.new(STDOUT)
      set :raise_errors, true
      set :show_exceptions, :true
    end

    register Sinatra::Cache
    set :cache_enabled, true

    before do
      @user_logged = session[:user]
      @js = :application
      @css = :application
    end

  end

end

require_relative 'actions/admin'
require_relative 'actions/login'
require_relative 'actions/public'
require_relative 'actions/backend'
