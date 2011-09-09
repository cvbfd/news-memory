require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sinatra'
require 'rack-flash'
require 'erb'
require 'json'

require 'webpage-archivist/migrations'
require_relative 'lib/migrations'
require 'webpage-archivist'
require_relative 'lib/models'

require_relative 'lib/countries'

WebpageArchivist::Snapshoter.height= 720
WebpageArchivist::Snapshoter.thumbnail_crop_height= 720

module NewsMemory

  ARCHIVIST = WebpageArchivist::WebpageArchivist.new

  class Server < Sinatra::Base

    set :views, File.dirname(__FILE__) + '/views'
    set :public, File.dirname(__FILE__) + '/public'

    use Rack::Session::Pool
    require 'rack/openid'
    use Rack::OpenID
    use Rack::Flash

    require_relative 'lib/helpers'
    helpers Sinatra::NewsMemoryHelper

    configure :development do
      WebpageArchivist::DATABASE.loggers << Logger.new(STDOUT)
      set :raise_errors, true
      set :show_exceptions, :true
    end

    before do
      @user_logged = session[:user]
      @css_include = []
      @js_include = []
    end

    get '/newspaper' do
      if params[:newspaper]
        redirect "/newspaper/#{params[:newspaper]}"
      else
        redirect '/'
      end
    end

    get '/date' do
      if params[:date]
        redirect "/date/#{params[:date].gsub("/", "-")}"
      else
        redirect '/'
      end
    end

    get '/country' do
      if params[:country]
        redirect "/country/#{params[:country]}"
      else
        redirect '/'
      end
    end

    get '/' do
      list_common
      @snapshots = WebpageArchivist::Instance.eager(:webpage).filter(:snapshot => true).limit(100).order(:created_at.desc).all
      erb :'index.html'
    end

    get /\/newspaper\/(\d+)/ do |id|
      newspaper = Newspaper[id]
      unless newspaper
        redirect '/'
      else
        list_common
        @title = newspaper.name
        @snapshots = WebpageArchivist::Instance.eager(:webpage).filter(:snapshot => true).filter(:webpage_id => newspaper.webpage_id).limit(100).order(:created_at.asc).all
        erb :'index.html'
      end
    end

    get /\/country\/([A-Z]{2})/ do |id|
      list_common
      @title = Countries::CODES_TO_COUNTRIES[id]
      @snapshots = WebpageArchivist::Instance.eager(:webpage).filter(:snapshot => true).filter(:webpage_id => Newspaper.filter(:country => id).select(:webpage_id)).limit(100).order(:created_at.desc).all
      erb :'index.html'
    end

    get /\/date\/(\d{2})-(\d{2})-(\d{4})/ do |day, month, year|
      list_common
      @title = "#{day}/#{month}/#{year}"
      date_ruby = DateTime.civil(year.to_i, month.to_i, day.to_i)
      @snapshots = WebpageArchivist::Instance.eager(:webpage).filter(:snapshot => true).filter('created_at >= ? and created_at < ?', date_ruby, date_ruby + 1).limit(100).order(:created_at.asc).all
      erb :'index.html'
    end

    private

    def list_common
      @newspapers = Newspaper.order(:name.asc)
      @countries = Newspaper.select(:country).distinct.collect { |n| [n.country, Countries::CODES_TO_COUNTRIES[n.country]] }.sort { |a, b| a[1] <=> b[1] }
    end

  end

end

require_relative 'actions/admin'
require_relative 'actions/login'
