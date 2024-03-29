# encoding: UTF-8

# session management
module NewsMemory

  class Server

    get '/login' do
      if resp = request.env['rack.openid.response']
        if resp.status == :success
          session[:user] = resp
          redirect '/reader'
        else
          halt 404, "Error: #{resp.status}"
        end
      elsif ENV['OPENID_URI']
        openid_params = {:identifier => ENV['OPENID_URI']}
        if params[:return_to]
          openid_params[:return_to] = params[:return_to]
        end
        headers 'WWW-Authenticate' => Rack::OpenID.build_header(openid_params)
        halt 401, 'got openid?'
      else
        redirect '/reader'
      end
    end

    get '/logout' do
      session[:user] = nil
      flash[:notice] = 'Logout'
      redirect '/'
    end

    helpers do

      def logged!
        if (!ENV['OPENID_URI']) || @user_logged
          true
        elsif resp = request.env['rack.openid.response']
          if resp.status == :success
            session[:user] = resp
            true
          else
            halt 404, "Error: #{resp.status}"
            false
          end
        else
          redirect "/login?return_to=#{CGI::escape(request.url)}"
          false
        end
      end

    end

  end

end