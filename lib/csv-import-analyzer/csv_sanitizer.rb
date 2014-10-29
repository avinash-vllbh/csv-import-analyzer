require "smarter_csv"
require "tempfile"
require "pry"
require_relative "analyzer/delimiter_identifier"
require_relative "helpers/string_class_extensions"
require_relative "helpers/common_functions"
require_relative "helpers/errors"
require_relative "csv_datatype_analysis"

module CsvImportAnalyzer
  class CsvSanitizer
    include CsvImportAnalyzer::Helper
    include CsvImportAnalyzer::DelimiterIdentifier

    def process(filename, options)

      options = defaults.merge(options)
      if File.exist?(filename)
        #first thing to do - find the delimiter of the file.
        delimiter = identify_delimiter(filename)
        options[:delimiter] = delimiter
        # create a tempfile to update any changes being made
        temp_file, processed_file = create_tempfiles(filename, options)
        options[:temp_file] = temp_file.path
        line_count = 1
        File.foreach(filename) do |line|
          #Check if the line is empty - no point in processing empty lines
          if line.length > 1
            line = replace_line_single_quotes(line,delimiter)
            begin
              line = CSV.parse_line(line, {:col_sep => delimiter})
            rescue CSV::MalformedCSVError
              ##
              # MalformedCSVError is due to illegal quoting or unclosed quotes
              # Try to add a quote at the end and resume processing
              # Log the changes to report
              temp_file.write("MalformedCSVError at line #{line_count}")
              line = line.insert(-2, "\"")
              line = CSV.parse_line(line, {:col_sep => delimiter})
            end
            line = replace_null_values(line)
            processed_file.write(line.to_csv({:col_sep => delimiter, :converters => :numeric}))
          end
          line_count += 1
        end
        temp_file.close
        processed_file.close
        # Cleaned the file - Now analyze for datatypes
        CsvImportAnalyzer::CsvDatatypeAnalysis.new(options).datatype_analysis
      else
        FileNotFound.new
      end
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
      pattern = "#{delimiter}'.*?'#{delimiter}" # set the pattern to opening and closing single quote found between delimiters
      res = line.gsub(/#{pattern}/)
      result = res.each { |match|
        replace = "#{delimiter}\""
        replace = "\|\"" if delimiter == "\\|"
        match = match.gsub(/^#{delimiter}'/,replace)
        replace = "\"#{delimiter}"
        replace = "\"\|" if delimiter == "\\|"
        match = match.gsub(/'#{delimiter}$/,replace)
      }
      result = result.gsub(/''/,'\'') #replace any single quote that might have been used twice to escape single quote before 
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

    # Returns the file handler for a temp file.
    # This tempfile holds any modifications being done to the file.
    def create_tempfiles(filename, options)
      options[:original_filename] = filename
      filename = File.basename(filename)
      processed_filename = File.join(Dir.tmpdir, "processed_"+filename)
      options[:filename] = processed_filename
      # filename += Time.now.strftime("%Y%m%d%H%M%S")
      # temp_file = Tempfile.new(filename)
      # temp_file = File.open(File.join(Dir.tmpdir, filename), "w+")
      temp_file = File.join(Dir.tmpdir, "error_report_"+filename)
      temp_file = File.open(temp_file, "w+")
      processed_file = File.open(processed_filename, "w+")
      return temp_file, processed_file
    end
  end
end
