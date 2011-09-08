WebpageArchivist::Migrations.migration 'news-memory tables' do
  WebpageArchivist::DATABASE.create_table :newspapers do
    primary_key :id
    String :name, :size => 250, :null => false, :index => true, :unique => true
    String :uri, :size => 5000, :null => false

    String :country, :size => 2, :null => false, :index => true, :unique => false
    String :wikipedia_uri, :size => 5000, :null => false
    foreign_key :webpage_id, :webpages, :null => false
  end
end

WebpageArchivist::Migrations.new.run
