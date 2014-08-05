require "smarter_csv"
require "tempfile"
require "pry"
require_relative "helpers/datatype_validation"

module CsvImportAnalyzer
  class CsvDatatypeAnalysis

    #Create a getter and setter for csv_column_datatypes array to be a instance variable to be used for processing to determine dataypes
    attr_accessor :csv_column_datatypes

    #Initialize the csv_column_datatypes to a hash that would contain a hash of hashes during the course of execution
    def initialize(options)
      @options = options
      self.csv_column_datatypes = {}
    end
    
    def options
      @options
    end

    
    # Process a chunk of csv file for all possible datatypes towards each column in the row
    def datatype_analysis(filename)
      SmarterCSV.process(filename, {:col_sep => delimiter, :chunk_size => chunk_size, 
        :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
        chunk.each do |row|
          row.each do |key, value|
            unless value == "" || value.nil? || value == "NULL"
              datatype = determine_dataype(value)
              add_to_datatype(key, datatype.to_sym)
            end
          end
        end
        break
      end
      finalize_datatypes_for_csv
      puts csv_column_datatypes
    end

    private

    def delimiter
      return options[:delimiter]
    end

    def chunk_size
      return options[:chunk]
    end

    #Call DatatypeValidator in helper module to process the possible datatype for the value
    #Is this the right way to hide dependency on the external classes or objects
    #May be a static would do ? Should I create an object and call method on the object each time rather than instantiate a new object each time ??
    def determine_dataype(value)
      return CsvImportAnalyzer::Helper::DatatypeValidator.new().validate_field(value)
    end

    # Build the hash of hashes which hold the count of different possible datatypes for each row
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

    #Finalize the datatype for each column, A column datatype would be set to varchar or string if atleast of it's values tend to be string
    #If the column doesn't have any possible strings then assign the datatype to column with maximum count of identified possibilites
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
  end
end

CsvImportAnalyzer::CsvDatatypeAnalysis.new({:delimiter => ",", :chunk => 20}).datatype_analysis("sampleTab.csv")