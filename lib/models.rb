module NewsMemory

  class Newspaper < Sequel::Model
    
    many_to_one :webpage, :class => WebpageArchivist::Webpage

    def validate
      super
      validates_presence [:uri, :name, :wikipedia_uri, :country]
      validates_max_length 5000, :uri
      validates_max_length 5000, :wikipedia_uri
      validates_max_length 250, :name
      validates_max_length 2, :country
      validates_min_length 2, :country
      validates_unique :name, :message => "[#{self.name}] is already taken"
      if self.uri
        begin
          URI.parse self.uri
        rescue URI::InvalidURIError
          errors.add('uri', "[#{self.uri}] is not a valid uri")
        end
      end
      if self.wikipedia_uri
        begin
          URI.parse self.wikipedia_uri
        rescue URI::InvalidURIError
          errors.add('wikipedia_uri', "[#{self.wikipedia_uri}] is not a valid uri")
        end
      end
    end

  end

end

module WebpageArchivist

  class Webpage < Sequel::Model

    one_to_one :newspaper, :class => NewsMemory::Newspaper

  end

end
