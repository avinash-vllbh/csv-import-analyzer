require "smarter_csv"
require "tempfile"
require_relative "analyzer/delimiter_identifier"
require_relative "helpers/string_class_extensions"
require_relative "helpers/common_functions"
require_relative "helpers/errors"
require_relative "csv_datatype_analysis"

module CsvImportAnalyzer
  class CsvSanitizer
    include CsvImportAnalyzer::Helper
    include CsvImportAnalyzer::DelimiterIdentifier

    ###
    # Public interface for the entire library
    # What id does?
    #      Sets "options" varaible by merging default values and passed values
    #      Finds the delimiter by analyzing a sample
    #      Sanitizes or preprocesses the csv file by creating a temporary processed file
    #               Replacing null and empty values with NULL
    #               Replace single quotes with double quotes if needed
    #      Handle CSVMalformedError by logging the error to error report
    # Passes the options to DatatypeAnalysis
    ###
    def process(filename, options)
      options = defaults.merge(options)
      if File.exist?(filename)
        delimiter = identify_delimiter(filename)
        options[:delimiter] = delimiter
        # create tempfiles to update any changes being made
        temp_file, processed_file = create_tempfiles(filename, options)
        options[:temp_file] = temp_file.path
        line_count = 1
        File.foreach(filename) do |line|
          if line.length > 1 #Check if the line is empty - no point in processing empty lines
            line = replace_line_single_quotes(line,delimiter)
            begin
              line = CSV.parse_line(line, {:col_sep => delimiter})
            rescue CSV::MalformedCSVError
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
        options[:rows] = line_count
        temp_file.close
        processed_file.close
        # Cleaned the file - Now analyze for datatypes
        CsvImportAnalyzer::CsvDatatypeAnalysis.new(options).datatype_analysis
      else
        FileNotFound.new
      end
    end

    private

    ###
    # Hash of default values that would be merged with user passed in values
    # returns [Hash] defaults
    ###
    def defaults
      {
        :metadata_output => nil,      # To be set if metadata needs to be printed to a file
        :processed_input => nil,      # To be set if processed input is needed
        :unique => 10,                # Threshold for number of defaults values that needs to identified
        :check_bounds => true,        # Option to check for min - max bounds for each column [true => find the bounds]
        :datatype_analysis => 200,    # Number of rows to be sampled for datatype analysis
        :chunk => 200,                # Chunk size (no of rows) that needs to processed in-memory [Important not to load entire file into memory]
        :database => [:pg, :mysql],   # Databases for which schema needs to be generated
        :quote_convert => true,       # Convert any single quotes to double quotes
        :replace_nulls => true,       # Replace nulls, empty's, nils, Null's with NULL
        :out_format => :json          # Set what type of output do you need as analysis
      }
    end

    ###
    # Replaces single quotes with doubles in each line
    # Escapes the double quotes if it's between two single quotes before
    # returns [String] result
    ###
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

    ###
    # Uses ruby tempfile to create temp files for
    #                 1. Store processed file
    #                 2. Error reporting
    # Returns the file handler for a temp file.
    # This tempfile holds any modifications being done to the file.
    ###
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
