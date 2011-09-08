require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'sinatra'

require 'rack-flash'
require 'erb'


require 'webpage-archivist/migrations'
require_relative 'lib/migrations'
require 'webpage-archivist'
require_relative 'lib/models'

require_relative 'lib/countries'
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

    before do
      @user_logged = session[:user]
      @css_include = []
      @js_include = []
    end

    get '/' do
      erb :'index.html'
    end

  end

end

require_relative 'actions/admin'
require_relative 'actions/login'
