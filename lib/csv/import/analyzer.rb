require "smarter_csv"
require "tempfile"
require "analyzer/delimiter_identifier"

module Csv
  module Import
    module Analyzer

      def self.defaults
        {
          :metadata_output => nil, 
          :processed_input => nil, 
          :unique => 10, 
          :chunk => 20, 
          :skip => 0, 
          :database => nil, 
          :quote_convert => true, 
          :replace_nulls => true
        }
      end

      def self.process(filename, options)
        puts defaults.merge(options)

        file = Tempfile.new("csv-import.csv")
        puts File.absolute_path(file)

        test = SmarterCSV.process('/home/avinash/Desktop/process_csv/samples/sampleTab.csv')
        puts test
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
      def replace_null_columns(line)
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
end
