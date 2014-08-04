require "smarter_csv"
require "tempfile"
require_relative "analyzer/delimiter_identifier"

module CsvImportAnalyzer
  class CsvSanitizer

    def process(filename, options)

      options = defaults.merge(options)
      skip_lines = options[:skip]
      puts options[:skip]
      delimiter = CsvImportAnalyzer::DelimiterIdentifier.identify_delimiter(filename)
      options[:delimiter] = delimiter

      # file = Tempfile.new("csv-import.csv")
      # puts File.absolute_path(file)

      File.foreach(filename) do |line|
        if skip_lines > 0
          skip_lines = skip_lines - 1
        else
          #Check if the line is empty
          if line.length > 1
            line = replace_line_single_quotes(line,delimiter)
            begin
              line = CSV.parse_line(line, {:col_sep => delimiter})
            rescue CSV::MalformedCSVError => error
              line = "#{line}\""
              # puts "#{error}"
              # puts line
              # puts "Please correct the above line and re-enter"
              # line = gets.chomp
              line = CSV.parse_line(line, {:col_sep => delimiter})
            end
            line = replace_null_values(line)
            puts line
          end
        end
      end


    end

    private

    def defaults
      {
        :metadata_output => nil, 
        :processed_input => nil, 
        :unique => 10, 
        :datatype_analysis => 10,
        :chunk => 20, 
        :skip => 0, 
        :database => nil, 
        :quote_convert => true, 
        :replace_nulls => true
      }
    end

    def replace_line_single_quotes(line, delimiter)
      delimiter = "\\|" if delimiter == "|"
      pattern = "#{delimiter}'.*?'#{delimiter}"
      res = line.gsub(/#{pattern}/)
      result = res.each { |match|
        replace = "#{delimiter}\""
        replace = "\|\"" if delimiter == "\\|"
        match = match.gsub(/^#{delimiter}'/,replace)
        replace = "\"#{delimiter}"
        replace = "\"\|" if delimiter == "\\|"
        match = match.gsub(/'#{delimiter}$/,replace)
      }
      result = result.gsub(/''/,'\'')
      return result
    end

    # Replace all nil, "NAN", empty values with NULL for maintaining consistency during database import
    def replace_null_values(line)
      line.each do |value|
        if(value == nil || value == "\\N" || value == "nil" ||value == "" ||value == "NAN")
          replace_index = line.index(value)
          line[replace_index] = "NULL"
        end
      end
      return line
    end

  end
end
