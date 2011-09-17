# encoding: UTF-8

module NewsMemory

  class Server

    helpers do

      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['BACKEND_LOGIN'] || 'admin', ENV['BACKEND_PASSWORD'] || 'admin']
      end

    end

    get '/backend/snapshots' do
      protected!
      snapshots
      'OK'
    end

  end

end