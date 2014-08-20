require_relative "../helpers/string_class_extensions"
require 'pry'

module CsvImportAnalyzer
  module DelimiterIdentifier

    # attr_accessor :delimiter, :delimiter_count

    def delimiter
      @delimiter ||= [",", ";", "\t", "|"]
    end

    def delimiter_count
      @delimiter_count ||= Hash[delimiter.map {|v| [v,0]}]
      @delimiter_count
    end

    def getting_contents_of_quoted_values(input)
      #return a join of all the strings inside quotes inside a line
      input.scan(/".*?"/).join
    end

    def count_occurances_delimiter(line)
      delimiter_count.keys.each do |key|
        #Count the occurances of delimiter in a line
        total_count_delimiter = line.substr_count(key)
        #count the occurances of delimiter between quotes inside a line to disregard them
        quoted_delimiter_count = getting_contents_of_quoted_values(line).substr_count(key)
        delimiter_count[key] += total_count_delimiter - quoted_delimiter_count
      end
    end

    def return_plausible_delimiter
      return delimiter_count.key(delimiter_count.values.max)
    end

    def identify_delimiter(filename_or_sample)
      #filename_or_sample input can be either a File or an Array or a string - Return delimiter for File or an Array of strings (if found)
      if filename_or_sample.class == String
        if File::exists?(filename_or_sample)
          current_line_number = 0
          File.foreach(filename_or_sample) do |line|
            count_occurances_delimiter(line)
            current_line_number += 1
            if current_line_number > 3
              break
            end
          end
        else
          # count_occurances_delimiter(filename_or_sample)
          return FileNotFound.new
        end
        return_plausible_delimiter
      elsif filename_or_sample.class == Array
        filename_or_sample.each do |line|
          count_occurances_delimiter(line)
        end
        return_plausible_delimiter
      else
        InvalidInput.new
      end
    end
  end
end

# puts CsvImportAnalyzer::DelimiterIdentifier.identify_delimiter("/home/avinash/Desktop/csv-import-analyzer/spec/fixtures/sample.csv")