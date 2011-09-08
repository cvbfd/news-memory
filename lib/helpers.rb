require 'sinatra/base'

class Object

  # An object is blank if it's false, empty, or a whitespace string.
  # For example, "", "   ", +nil+, [], and {} are blank.
  #
  # This simplifies:
  #
  #   if !address.nil? && !address.empty?
  #
  # ...to:
  #
  #   if !address.blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

module Sinatra

  module NewsMemoryHelper

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def input_text(name, label, value = '', size = nil, id = nil, type = 'text')
      "<li><label for=\"#{name}\">#{label}</label>" +
          "<input#{id ? " id=\"#{id}\"" : '' } name=\"#{name}\" type=\"#{type}\" value=\"#{value}\"#{size ? " size=\"#{size}\"" : ''}/><li>"
    end

    def input_file(name, label)
      "<li><label for=\"#{name}\">#{label}</label>" +
          "<input name=\"#{name}\" type=\"file\"/><li>"
    end

    def input_checkbox(name, label, value = false, id = nil)
      "<li><label for=\"#{name}\">#{label}</label>" +
          "<input#{id ? " id=\"#{id}\"" : '' } name=\"#{name}\" type=\"checkbox\"#{value ? ' checked="checked"' : ''}\"/></li>"
    end

    def input_combobox(name, label, possible_values, selected_value = nil)
      "<li><label for=\"#{name}\">#{label}</label>" +
          "<select name=\"#{name}\">#{input_select_content(possible_values, selected_value)}</select></li>"
    end

    def input_select_content possible_values, selected_value = nil
      possible_values.collect { |key, value| "<option value=\"#{value}\"#{(value == selected_value) ? ' selected="selected' : ''}>#{key}</option>" }.join('')
    end

    def input_from_list possible_values
      possible_values.collect { |value| "<option>#{value}</option>" }.join('')
    end

    def display_newspapers_select newspapers, id = nil
      r = "<li><label for=\"newspaper\">newspaper</label> <select name=\"newspaper\"#{id ? "id=\"#{id}\"" : ''}>"
      newspapers.each do |newspaper|
        r << "<option value=\"#{newspaper.id}\">#{newspaper.name}</option>"
      end
      r << '</select></li>'
    end

    def display_date_time date, between = ''
      if date
        date.strftime("%d/%m/%Y #{between}%H:%M:%S")
      end
    end

  end

  helpers NewsMemoryHelper

end
