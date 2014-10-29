require "smarter_csv"
require "tempfile"
require_relative "helpers/datatype_validation"
require_relative "analyzer/csv_check_bounds"
require_relative "helpers/common_functions"
require_relative "sql_query_builder"
require "pry"

module CsvImportAnalyzer
  class CsvDatatypeAnalysis
    include CsvImportAnalyzer::Helper
    include CsvImportAnalyzer::DatatypeValidator

    attr_accessor :csv_column_datatypes, :nullable

    def initialize(options)
      @options = options
      @csv_column_datatypes = {}
      @nullable = []
    end
    
    def options
      @options
    end

    def filename
      @options[:filename]
    end

    ###
    # Process a chunk of csv file for all possible datatypes towards each column in the row
    # This datatype analysis is used for analyzing,
    #                 Min - Max values of each column
    #                 Distinct values of each column
    #                 Enumeration eligibility
    def datatype_analysis
      SmarterCSV.process(filename, {:col_sep => delimiter, :chunk_size => chunk_size, 
        :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
        chunk.each do |row|
          row.each do |key, value|
            unless null_like?(value)
              datatype = determine_dataype(value)
              add_to_datatype(key, datatype.to_sym)
            else             
              nullable.push(key) unless nullable.include?(key)
            end
          end
        end
        break
      end
      options[:csv_datatype_analysis] = csv_column_datatypes.clone # To retain the current state of csv_column_datatypes since it's altered further
      finalize_datatypes_for_csv
      options[:csv_column_datatypes] = csv_column_datatypes
      options[:nullable] = nullable
      take_further_actions
    end

    private

    def delimiter
      return options[:delimiter]
    end

    def chunk_size
      return options[:chunk]
    end

    ###
    # Call DatatypeValidator in helper module to process the possible datatype for the value
    # Is this the right way to hide dependency on the external classes or objects
    # May be a static would do ? Should I create an object and call method on the object each time rather than instantiate a new object each time ??
    ###
    def determine_dataype(value)
      return validate_field(value)
    end

    ###
    # Build the hash of hashes which hold the count of different possible datatypes for each row
    ###
    def add_to_datatype(key, datatype)
      if csv_column_datatypes[key].nil?
        csv_column_datatypes[key] = {datatype => 1}
      else
        if csv_column_datatypes[key][datatype].nil?
          csv_column_datatypes[key][datatype] = 1
        else
          csv_column_datatypes[key][datatype] += 1
        end
      end
    end

    ###
    # Finalize the datatype for each column.
    # A column datatype would be set to varchar or string if even one of it's values tend to be string
    # If the column doesn't have any possible strings then assign the datatype to column with maximum count of identified possibilites
    ###
    def finalize_datatypes_for_csv
      csv_column_datatypes.map { |column_name, possible_datatypes|
        #If there is string type even atleast 1 there is no other option but to set the datatype to string => varchar
        if possible_datatypes.has_key?(:string)
          csv_column_datatypes[column_name] = :string
        else
          #set the max occurance datatype as the datatype of column
          csv_column_datatypes[column_name] = possible_datatypes.key(possible_datatypes.values.max)
        end
      }
    end

    ###
    # Decide if simple datatype analysis is enough or proced further
    # Proceed further would be to
    #                 Identify min and max bounds for each column
    #                 Identify if the number distinct values are less than set threshold
    ###
    def take_further_actions
      if options[:check_bounds]
        min_max_bounds = CsvImportAnalyzer::CsvCheckBounds.new(options)
        res = min_max_bounds.get_min_max_values
        options[:min_max_bounds] = res[:min_max]
        options[:uniques] = res[:uniques]
      end
      query = CsvImportAnalyzer::SqlQueryBuilder.new(options)
      query.generate_query
    end
  end
end
