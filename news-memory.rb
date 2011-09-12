# encoding: UTF-8

require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sinatra'
require 'rack-flash'
require 'erb'
require 'json'
require 'sinatra/assetpack'

require 'webpage-archivist/migrations'
require_relative 'lib/migrations'
require 'webpage-archivist'
require_relative 'lib/models'

require_relative 'lib/countries'

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

    before do
      @user_logged = session[:user]
      @js = :application
      @css = :application
    end

    assets do
      serve '/js', from: 'assets/js'
      serve '/css', from: 'assets/css'

      js :application, '/js/news-memory.js',
         [
            '/js/jquery.js',
            '/js/fancybox/fancybox.js',
            '/js/datepicker/date.js',
            '/js/datepicker/datePicker.js',
            '/js/public.js'
         ]

      js :admin, '/js/news-memory-admin.js.js',
         [
            '/js/jquery.js',
            '/js/admin.js'
         ]

      css :application, '/css/news-memory.css',
          [
            '/css/application.css',
            '/css/fancybox/jquery.fancybox.css',
            '/css/datepicker/datepicker.css'
          ]

      css :admin, '/css/news-memory-admin.css',
          [
            '/css/application.css',
            '/css/admin.css'
          ]

    end

    get '/about' do
      @title = 'About'
      erb :'about.html'
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
      @snapshots = index_list(0)
      @more_path = "/json/"
      erb :'index.html'
    end

    get /\/json\/(\d+)/ do |id|
      json index_list(id.to_i)
    end

    get /\/json\/newspaper\/(\d+)\/(\d+)/ do |id, page|
      newspaper = Newspaper[id]
      unless newspaper
        halt 404
      else
        json newspaper_list(newspaper, page.to_i)
      end
    end

    get /\/newspaper\/(\d+)/ do |id|
      newspaper = Newspaper[id]
      unless newspaper
        halt 404
      else
        list_common
        @title = newspaper.name
        @subtitle = "<a href=\"#{newspaper.uri}\">Website</a> – <a href=\"#{newspaper.wikipedia_uri}\">Wikipedia page</a>"
        @snapshots = newspaper_list(newspaper, 0)
        @more_path = "/json/newspaper/#{id}/"
        erb :'index.html'
      end
    end

    get /\/json\/country\/(\d+)\/(\d+)/ do |id, page|
      json country_list(id, page.to_i)
    end

    get /\/country\/([A-Z]{2})/ do |id|
      list_common
      @title = Countries::CODES_TO_COUNTRIES[id]
      @snapshots = country_list(id, 0)
      @more_path = "/json/country/#{id}/"
      erb :'index.html'
    end

    get /\/json\/date\/(\d{2})-(\d{2})-(\d{4})\/(\d+)/ do |day, month, year, page|
      date_ruby = DateTime.civil(year.to_i, month.to_i, day.to_i)
      json date_list(date_ruby, page.to_i)
    end

    get /\/date\/(\d{2})-(\d{2})-(\d{4})/ do |day, month, year|
      list_common
      @title = "#{day}/#{month}/#{year}"
      date_ruby = DateTime.civil(year.to_i, month.to_i, day.to_i)
      @snapshots = date_list(date_ruby, 0)
      @more_path = "/json/date/#{day}-#{month}-#{year}/"
      erb :'index.html'
    end

    private

    def list_common
      @min_date = WebpageArchivist::Instance.filter(:snapshot => true).filter(:webpage_id => Newspaper.select(:webpage_id)).select(:created_at).order(:created_at.asc).first
      if @min_date
        @min_date = @min_date.created_at.strftime("%d/%m/%Y")
      end
      @newspapers = Newspaper.order(:name.asc)
      @countries = Newspaper.select(:country).distinct.collect { |n| [n.country, Countries::CODES_TO_COUNTRIES[n.country]] }.sort { |a, b| a[1] <=> b[1] }
    end

    def index_list page
      WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter(:webpage_id => Newspaper.select(:webpage_id)).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.desc).all
    end

    def newspaper_list newspaper, page
      WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter(:webpage_id => newspaper.webpage_id).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.desc).all
    end

    def country_list id, page
      WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter(:webpage_id => Newspaper.filter(:country => id).select(:webpage_id)).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.desc).al
    end

    def date_list date, page
      WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter('created_at >= ? and created_at < ?', date, date + 1).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.asc).all
    end

    def json data
      content_type :json
      data.collect do |i|
        {
            :id => i.id,
            :name => i.webpage.name,
            :date => i.created_at.to_time.to_i,
            :newspaper => i.webpage.newspaper.id,
            :snapshot => "/snapshots/#{i.snapshot_path}",
            :small_snapshot => "/snapshots/#{i.small_snapshot_path}"
        }
      end.to_json
    end

  end

end

require_relative 'actions/admin'
require_relative 'actions/login'
