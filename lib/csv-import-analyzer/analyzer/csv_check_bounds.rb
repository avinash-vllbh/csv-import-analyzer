require 'smarter_csv'
require 'pry'
require_relative "../helpers/common_functions"


module CsvImportAnalyzer
  class CsvCheckBounds
    include CsvImportAnalyzer::Helper
    attr_accessor :min_max_bounds, :distinct_values, :csv_column_datatypes, :options, :nullable, :max_distinct_values

    def initialize(options)
      @csv_column_datatypes = options[:csv_column_datatypes]
      @options = options
      @min_max_bounds = {}
      @distinct_values = {}
      @nullable = options[:nullable]

    end

    def filename
      return options[:filename]
    end
    def chunk_size
      return options[:chunk_size]
    end
    def delimiter
      return options[:delimiter]
    end
    def max_distinct_values
      @max_distinct_values ||= Integer(options[:unique]) + 1
    end

    # Public interface that is called - Processes the CSV file for min & max values for each column
    def get_min_max_values
      SmarterCSV.process(filename, {:col_sep => delimiter, :chunk_size => chunk_size, 
      :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
        chunk.each do |row|
          row.each do |key, value|
            unless null_like?(value)
              process_min_max_for_column(key, value)
              process_distinct_values(key, value)
            else             
              nullable.push(key) unless nullable.include?(key)
            end
          end
        end
      end
      return {:min_max => min_max_bounds, :uniques => distinct_values}
    end

    private

    ##
    #If the key is of String type then we find the max length of it
    ##
    def process_min_max_for_column(key, value)
      if min_max_bounds[key].nil?
        unless csv_column_datatypes[key] == :string
          min_max_bounds[key] = {:min => value, :max => value}
        else
          min_max_bounds[key] = {:min => value.length, :max => 0}
        end
      end
      add_bounds(key, value)
    end

    ##
    #Method which decides on the min max values for each key and according to the passsed in value
    ##
    def add_bounds(key, value)
      if csv_column_datatypes[key] == :string
        min_max_bounds[key][:min] = value.length if value.length < min_max_bounds[key][:min]
        min_max_bounds[key][:max] = value.length if value.length > min_max_bounds[key][:max]
      else
        min_max_bounds[key][:min] = value if value < min_max_bounds[key][:min]
        min_max_bounds[key][:max] = value if value > min_max_bounds[key][:max]
      end
    end

    ##
    #Processes the max number of distinct values set for each column
    ##
    def process_distinct_values(key, value)
      if distinct_values[key].nil?
        distinct_values[key] = [value]
      else
        if distinct_values[key].size > max_distinct_values
        else
          distinct_values[key].push(value) unless distinct_values[key].include?(value)
        end
      end
    end
    
  end
end