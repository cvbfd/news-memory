# encoding: UTF-8

module NewsMemory

  class Server

    assets do
      serve '/js', from: 'assets/js'
      serve '/css', from: 'assets/css'

      js :application, '/js/news-memory.js',
         [
             '/js/jquery.js',
             '/js/bigtext.js',
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

    not_found do
      erb :'404.html'
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
      @more_path = "/json/index"
      erb :'index.html'
    end

    get /\/json\/index\/(\d+)\.json/ do |id|
      content_type :json
      cache_raw do
        json index_list(id.to_i)
      end
    end

    get /\/json\/newspaper\/(\d+)\/(\d+)\.json/ do |id, page|
      content_type :json
      cache_raw do
        newspaper = Newspaper[id]
        unless newspaper
          halt 404
        else
          json newspaper_list(newspaper, page.to_i)
        end
      end
    end

    get /\/newspaper\/(\d+)/ do |id|
      newspaper = Newspaper[id]
      unless newspaper
        halt 404
      else
        list_common
        @title = newspaper.name
        @subtitle = "<a href=\"#{newspaper.uri}\">Website</a> | <a href=\"#{newspaper.wikipedia_uri}\">Wikipedia page</a>"
        @snapshots = newspaper_list(newspaper, 0)
        @more_path = "/json/newspaper/#{id}/"
        erb :'index.html'
      end
    end

    get /\/json\/country\/([A-Z]{2})\/(\d+)\.json/ do |id, page|
      content_type :json
      cache_raw do
        json country_list(id, page.to_i)
      end
    end

    get /\/country\/([A-Z]{2})/ do |id|
      list_common
      @title = Countries::CODES_TO_COUNTRIES[id]
      @snapshots = country_list(id, 0)
      @more_path = "/json/country/#{id}/"
      erb :'index.html'
    end

    get /\/json\/date\/(\d{2})-(\d{2})-(\d{4})\/(\d+)\.json/ do |day, month, year, page|
      content_type :json
      cache_raw do
        date_ruby = DateTime.civil(year.to_i, month.to_i, day.to_i)
        json date_list(date_ruby, page.to_i)
      end
    end

    get /\/date\/(\d{2})-(\d{2})-(\d{4})\.json/ do |day, month, year|
      list_common
      @title = "#{day}/#{month}/#{year}"
      date_ruby = DateTime.civil(year.to_i, month.to_i, day.to_i)
      @snapshots = date_list(date_ruby, 0)
      @more_path = "/json/date/#{day}-#{month}-#{year}/"
      erb :'index.html'
    end

    helpers do

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
        WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter(:webpage_id => Newspaper.filter(:country => id).select(:webpage_id)).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.desc).all
      end

      def date_list date, page
        WebpageArchivist::Instance.eager(:webpage => :newspaper).filter(:snapshot => true).filter('created_at >= ? and created_at < ?', date, date + 1).limit(PAGE_SIZE, page * PAGE_SIZE).order(:created_at.asc).all
      end

      def json data
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

      def wipe_cache

        index = File.join(settings.cache_output_dir, 'index.html')
        if File.exist? index
          File.unlink index
        end

        ['date', 'country', 'newspaper', 'json'].collect { |d| File.join(settings.cache_output_dir, d) }.each do |d|
          if File.exist?(d)
            Find.find(d) do |f|
              unless File.directory?(f)
                File.unlink f
              end
            end
          end
        end
      end

    end

  end

end
