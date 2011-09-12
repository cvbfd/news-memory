require 'addressable/uri'

module NewsMemory

  class Server

    get '/admin' do
      if check_logged
        @title = 'Configuration'
        @js = :admin
        @css = :admin
        @newspapers = Newspaper.order(:name.asc)
        erb :'admin.html', :cache => false
      end
    end

    post '/admin/add' do
      if check_logged
        if params[:wikipedia_uri].blank?
          flash[:error] = "No wikipedia uri"
        elsif params[:uri].blank?
          flash[:error] = "No uri"
        else
          begin
            w = Addressable::URI.parse(params[:wikipedia_uri]).normalize.to_s
            URI.parse w
            u = Addressable::URI.parse(params[:uri]).normalize.to_s
            webpage = NewsMemory::ARCHIVIST.add_webpage(u, params[:name])
            Newspaper.create(
                :name => params[:name],
                :uri => u,
                :wikipedia_uri => w,
                :webpage => webpage,
                :country => params[:country])
            flash[:notice] = 'Newspaper added'
            wipe_cache
          rescue URI::InvalidURIError => e
            flash[:error] = "Error during creation #{e}"
          rescue Sequel::ValidationFailed => e
            flash[:error] = "Error during creation #{e}"
          end
        end
        redirect '/admin'
      end
    end

    get '/admin/add' do
      redirect '/admin'
    end

    post '/admin/remove' do
      if check_logged
        newspaper = Newspaper[params[:newspaper]]
        if newspaper
          newspaper.delete
          flash[:notice] = 'Newspaper removed'
          wipe_cache
        else
          flash[:notice] = 'Newspaper not found'
        end
        redirect '/admin'
      end
    end

    get '/admin/remove' do
      redirect '/admin'
    end

    post '/admin/edit_newspaper' do
      if check_logged
        newspaper = Newspaper[params[:newspaper]]
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
            wipe_cache
          rescue Sequel::ValidationFailed => e
            flash[:error] = "Error during update #{e}"
          end
        else
          flash[:notice] = 'Newspaper not found'
        end
        redirect '/admin'
      end
    end

    get '/admin/edit_newspaper' do
      redirect '/admin'
    end

    post '/admin/snapshots' do
      if check_logged
        NewsMemory::ARCHIVIST.fetch_webpages(WebpageArchivist::Webpage.filter(:id => Newspaper.select(:webpage_id)))
        wipe_cache
        redirect '/admin'
      end
    end

    get '/admin/snapshots' do
      redirect '/admin'
    end

  end

end