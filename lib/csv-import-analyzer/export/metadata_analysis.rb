require 'json'
module CsvImportAnalyzer
  class MetadataAnalysis
    attr_accessor :metadata, :max_distinct_values
    def initialize(options)
      @options = options
      @metadata = {}
    end

    def options
      @options
    end

    def metadata
      @metadata
    end

    def header_datatypes
      @options[:csv_column_datatypes]
    end

    def header_datatype_analysis
      @options[:csv_datatype_analysis]
    end

    def nullable_columns
      @options[:nullable]
    end

    def databases
      @options[:database]
    end

    def create_queries
      @options[:create_query]
    end

    def import_queries
      @options[:import_query]
    end

    def unique_values
      @options[:uniques]
    end

    def max_distinct_values
      @max_distinct_values ||= Integer(options[:unique]) + 1
    end

    ###
    # Builds the metadata from the analysis done so far
    # Creates a new json file with the analysis added to it if options[:metadata_output] is set
    # returns JSON object of the metadata
    ###
    def metadata_print
      build_metadata_output
      if options[:metadata_output]
        if options[:out_format] == :json
          json_print_to_file
        end
        if options[:out_format] == :csv
          csv_print_to_file
        end
      end
      return JSON.pretty_generate(metadata)
    end


    private

    ###
    # Create or overwrite the metadata_output.json file if it already exists
    # Write the metadata to the file and close it
    ###
    def json_print_to_file
      outfile = File.open("metadata_output.json", "w")
      outfile << JSON.pretty_generate(metadata)
      outfile.close
    end

    ###
    # Priniting the metadat to csv - How to make sense of the csv print??
    # TODO: ADD support for returning data analysis as csv file
    ###
    def csv_print_to_file
      CSV.open("metadata_output.csv", "w") do |csv|
        metadata.each do |key, value|
          if value.class == Hash
            csv << [key]
            print_hash_to_csv(value, csv)
          else
            csv << [key, value]
          end
        end
      end
    end

    ###
    # Handle the key => value pairs to be printed as CSV files
    # Recursively prints the key and value
    ###
    def print_hash_to_csv(hash, csv_handler)
      if hash.class == Hash
        hash.each do |key, value|
          csv_handler << [key]
          print_hash_to_csv(value, csv_handler)
        end
      else
        csv_handler << [hash]
      end
    end

    ###
    # Build the metadata hash with need key value pairs
    # Add the analysis data to @metadata instance variable
    # E.g. metadata[:csv_file] means the metadata for csv file
    ###
    def build_metadata_output
      metadata[:csv_file] = add_file_metadata
      metadata[:data_manipulations] = add_data_manipulations
      metadata[:csv_headers] = add_header_metadata
      metadata[:sql] = add_sql_data
    end

    ###
    # Metadata of the file
    # adds the filename, file_path, record delimiter of the file along with processed file metadata
    # Returns a hash of file data
    ###
    def add_file_metadata
      file_data = {}
      file_data[:filename] = File.basename(options[:original_filename])
      file_data[:file_size] = File.size(options[:original_filename])
      file_data[:record_delimiter] = options[:delimiter]

      file_data[:processed_filename] = File.basename(options[:filename])
      file_data[:processed_file_path] = options[:filename]
      file_data[:processed_file_size] = File.size(options[:filename])
      file_data[:error_report] = options[:temp_file]
      # file_data[:rows] = options[:rows]
      # file_data[:columns] = options[:columns]
      return file_data
    end

    ###
    # Add the data manipulations done to the processed file
    # Currently only two types of manipulations
    #   replace all the nulls and empty values with NULL
    #   replace single quotes with double quotes
    # returns hash of data_manipulations
    ###
    def add_data_manipulations
      data_manipulations = {}
      data_manipulations[:replace_nulls] = options[:replace_nulls]
      data_manipulations[:replace_quotes] = options[:quote_convert]
      return data_manipulations
    end

    ###
    # builds a columns hash with metadata of each column
    # E.g 
    # "photo_id": {
    #   "datatype": "int",        => Tells the datatype is int
    #   "datatype_analysis": {    => gives the results of datatypes analyis done
    #                                  eventhough the column is determined to be int
    #                                  in reality it could have "int": 20, "float": "5"
    #                                  This would help the analyst to get a sense of data late on
    #     "int": 20
    #   },
    #   "distinct_values": "11+"  => Cotains an array of distinct values,
    #                                  if they are less than the threshold set
    #                      or
    #                   [1, 2, 3]
    # },
    def add_header_metadata
      columns = {}
      header_datatypes.keys.each do |column_name|
        begin
          columns[column_name] = {}
          columns[column_name][:datatype] = header_datatypes[column_name]
          columns[column_name][:datatype_analysis] = header_datatype_analysis[column_name]
          if unique_values[column_name].size > max_distinct_values
            columns[column_name][:distinct_values] = "#{max_distinct_values}+"
          else
            columns[column_name][:distinct_values] = unique_values[column_name]
          end
          if nullable_columns.include?(column_name)
            columns[column_name][:nullable] = true
          end
        rescue Exception => e
          puts e
        end
      end
      return columns
    end

    ###
    # Add the queries for each database type specified
    # build an sql hash with both create and import statements
    ###
    def add_sql_data
      sql = {}
      databases.each do |db|
        sql[db] = {}
        sql[db][:create_query] = create_queries[db]
        sql[db][:import_query] = import_queries[db]
      end
      return sql
    end

  end
end
