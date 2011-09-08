module NewsMemory

  class Server

    get '/admin' do
      if check_logged
        @title = 'Configuration'
        @css_include << 'admin'
        @newspapers = Newspaper.order(:name.asc)
        erb :'admin.html'
      end
    end

    post '/admin/add' do
      if check_logged
        begin
          URI.parse params[:wikipedia_uri]
          webpage = NewsMemory::ARCHIVIST.add_webpage(params[:uri], params[:name])
          Newspaper.create(
              :name => params[:name],
              :uri => params[:uri],
              :wikipedia_uri => params[:wikipedia_uri],
              :webpage => webpage)
          flash[:notice] = 'Newspaper added'
        rescue URI::InvalidURIError => e
          flash[:error] = "Error during newspaper creation #{e}"
        rescue Sequel::ValidationFailed => e
          flash[:error] = "Error during newspaper creation #{e}"
        end
        redirect '/admin'
      end
    end

    post '/admin/remove' do
      if check_logged
        newspaper = Newspaper.where(:id => params[:newspaper]).first
        if newspaper
          Feed.Newspaper.where(:id => params[:newspaper]).delete
          flash[:notice] = 'Newspaper removed'
        else
          flash[:notice] = 'Newspaper not found'
        end
        redirect '/admin'
      end
    end

    post '/admin/edit_newspaper' do
      if check_logged
        newspaper = Newspaper.where(:id => params[:newspaper]).first
        if newspaper
          begin
            newspaper.update(:name => params[:name],
                             :country => params[:country],
                             :uri => params[:uri],
                             :wikipedia_uri => params[:wikipedia_uri])
            newspaper.webpage.update(
                :name => params[:name],
                :uri => params[:uri])
            flash[:notice] = 'Newspaper updated'
          rescue Sequel::ValidationFailed => e
            flash[:error] = "Error during newspaper update #{e}"
          end
        else
          flash[:notice] = 'Newspaper not found'
        end
        redirect '/admin'
      end
    end


  end

end