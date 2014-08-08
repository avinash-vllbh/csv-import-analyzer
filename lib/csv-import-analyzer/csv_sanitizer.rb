require "smarter_csv"
require "tempfile"
require_relative "analyzer/delimiter_identifier"
require_relative "helpers/string_class_extensions"
require_relative "helpers/common_functions"
require_relative "csv_datatype_analysis"

module CsvImportAnalyzer
  class CsvSanitizer
    include CsvImportAnalyzer::Helper



    def process(filename, options)

      options = defaults.merge(options)
      #first thing to do - find the delimiter of the file.
      delimiter = CsvImportAnalyzer::DelimiterIdentifier.identify_delimiter(filename)
      options[:delimiter] = delimiter
      options[:filename] = filename

      File.foreach(filename) do |line|
        #Check if the line is empty - no point in processing empty lines
        if line.length > 1
          line = replace_line_single_quotes(line,delimiter)
          begin
            line = CSV.parse_line(line, {:col_sep => delimiter})
          rescue CSV::MalformedCSVError => error
            line = "#{line}\""
            line = CSV.parse_line(line, {:col_sep => delimiter})
          end
          line = replace_null_values(line)
        end
      end
      # Cleaned the file - Now analyze for datatypes
      CsvImportAnalyzer::CsvDatatypeAnalysis.new(options).datatype_analysis
    end

    private

    def defaults
      {
        :metadata_output => nil,
        :processed_input => nil,
        :unique => 10,
        :check_bounds => true,
        :datatype_analysis => 200,
        :chunk => 20,
        :database => [:pg, :mysql], 
        :quote_convert => true, 
        :replace_nulls => true,
        :out_format => :json
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
        if null_like?(value)
          replace_index = line.index(value)
          line[replace_index] = "NULL"
        end
      end
      return line
    end
  end
end
