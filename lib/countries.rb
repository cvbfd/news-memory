module NewsMemory

  module Countries

    CODES_TO_COUNTRIES = {}

    COUNTRIES_TO_CODE = {}

    REGEX = /\A([A-Z]{2})\s(.+)\n\z/

    File.open(File.join(File.dirname(__FILE__), 'countries.txt'), "r:utf-8").each_line do |l|
      if m = REGEX.match(l)
        CODES_TO_COUNTRIES[m[1]] = m[2]
        COUNTRIES_TO_CODE[m[2]] = m[1]
      end
    end

  end
end