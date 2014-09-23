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

    def json_print_to_file
      outfile = File.open("metadata_output.json", "w")
      outfile << JSON.pretty_generate(metadata)
      outfile.close
    end

    # Priniting that csv from json is a mess - How to make pretty print ?
    def csv_print_to_file
      CSV.open("metadata_output.csv", "w") do |csv|
        binding.pry
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

    def build_metadata_output
      metadata[:csv_file] = add_file_metadata
      metadata[:data_manipulations] = add_data_manipulations
      metadata[:csv_headers] = add_header_metadata
      metadata[:sql] = add_sql_data
    end

    def add_file_metadata
      file_data = {}
      file_data[:filename] = File.basename(options[:filename])
      file_data[:file_size] = File.size(options[:filename])
      # file_data[:rows] = options[:rows]
      # file_data[:columns] = options[:columns]
      file_data[:record_delimiter] = options[:delimiter]
      return file_data
    end

    def add_data_manipulations
      data_manipulations = {}
      data_manipulations[:replace_nulls] = options[:replace_nulls]
      data_manipulations[:replace_quotes] = options[:quote_convert]
      return data_manipulations
    end

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
