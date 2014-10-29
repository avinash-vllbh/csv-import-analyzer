require_relative "query_builder/mysql_query_helper"
require_relative "query_builder/pg_query_helper"
require_relative "export/metadata_analysis"
module CsvImportAnalyzer
  class SqlQueryBuilder

    attr_accessor :create_query, :import_query, :csv_column_datatypes, :min_max_bounds, :nullable, :sql_helper_options

    ###
    # Since Building SQL is dependent on multiple things,
    # decided to go with an arguments hash that gets passed when creating an object for the class
    ###
    def initialize(args)
      @options = args
      @create_query = {}
      @import_query = {}
      @csv_column_datatypes = args[:csv_column_datatypes]
      @nullable = args[:nullable]
      @sql_helper_options = {:tablename => tablename, :filename => @options[:filename], :delimiter => @options[:delimiter]}
      @mysql_helper.extend(CsvImportAnalyzer::MysqlQueryHelper)
      @pg_helper.extend(CsvImportAnalyzer::PgQueryHelper)
    end

    def options
      @options
    end

    def databases
      options[:database]
    end

    def filename
      return options[:filename]
    end

    def tablename
      # May be optimize this, not run all three operations everytime filename method is called ??
      # May be creating filename as instance variable and using a double pipe will relive it from running everytime doesn't it??
      tablename = File.basename(options[:filename])
      tablename.gsub!(" ", "_")
      tablename.downcase!
      return tablename
    end

    def delimiter
      options[:delimiter]
    end

    def mysql_helper
      @mysql_helper
    end

    def pg_helper
      @pg_helper
    end

    ###
    # Goes through each of the columns datatypes and prepares SQL statements for
    #         1. Importing CSV files to database
    #         2. Create table schema for the files
    # Makes a function call to return the metadata analysis of the file
    ###
    def generate_query
      databases.each do |db|
        create_query[db] = ["create table #{tablename} ("]
      end
      csv_column_datatypes.each do |header, datatype|
        append_to_query = build_query_for_datatype(header, datatype)
        append_to_query.each do |key, value|
          create_query[key].push(value)
        end
      end
      prepare_sql_statements
      prepare_import_csv
      print_metadata_analysis
    end

    private

    ###
    # Based on the database type set in options
    # returns query part for the header (column name)
    ###
    def build_query_for_datatype(header, datatype)
      query = {}
      databases.each do |db|
        if db == :mysql
          query[db] = mysql_helper.form_query_for_datatype(header: header, datatype: datatype)
        else
          query[db] = pg_helper.form_query_for_datatype(header: header, datatype: datatype)
        end
      end
      unless nullable.include?(header)
        query.keys.each do |db|
          query[db] << " not null"
        end
      end
      return query
    end

    ###
    # based on database type set in options
    # returns import query for the database
    ###
    def prepare_import_csv
      databases.each do |db|
        if db == :mysql
          import_query[db] = mysql_helper.import_csv(tablename: tablename, filename: filename, delimiter: delimiter)
        elsif db == :pg
          import_query[db] = pg_helper.import_csv(tablename: tablename, filename: filename, delimiter: delimiter)
        end
      end
    end

    ###
    # prepares sql statements based on the query for each header formed earlier
    ###
    def prepare_sql_statements
      databases.each do |db|
        create_query[db][0] = create_query[db].first + " " + create_query[db][1]
        create_query[db].delete_at(1)
        create_query[db] = create_query[db].join(", ")
        create_query[db] << ");"
      end
    end

    ###
    # set's the create query and import query's in options
    # these fields will be added to the metadata later
    # instantiates MetadataAnalysis and passes options hash
    ###
    def print_metadata_analysis
      options[:create_query] = create_query
      options[:import_query] = import_query
      export = CsvImportAnalyzer::MetadataAnalysis.new(options)
      export.metadata_print
    end

  end
end
