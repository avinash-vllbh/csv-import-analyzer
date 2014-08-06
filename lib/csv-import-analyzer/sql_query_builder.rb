require 'pry'
require_relative "helpers/mysql_query_helper"
require_relative "helpers/pg_query_helper"
module CsvImportAnalyzer
  class SqlQueryBuilder
    attr_accessor :create_query, :import_query, :csv_column_datatypes, :min_max_bounds, :nullable, :sql_helper_options

    # Since Building SQL is dependent on multiple things,
    # decided to go with an argumnets hash that gets passed when creating an object for the class
    def initialize(args)
      @options = args
      @create_query = {}
      @import_query = {}
      @csv_column_datatypes = args[:csv_column_datatypes]
      @nullable = args[:nullable]
      @databases = [:pg, :mysql]
      @sql_helper_options = {:tablename => tablename, :filename => @options[:filename], :delimiter => @options[:delimiter]}
      @mysql_helper = CsvImportAnalyzer::Helper::MysqlQueryHelper.new(@sql_helper_options)
      @pg_helper = CsvImportAnalyzer::Helper::PgQueryHelper.new(@sql_helper_options)
    end

    def options
      @options
    end

    def databases
      @databases
    end

    def filename
      return options[:filename]
    end

    def tablename
      # May be optimize this, not run all three operations everytime filename method is called
      # May be creating filename as instance variable and using a double pipe will relive it from running everytime doesn't it?
      tablename = File.basename(options[:filename])
      tablename.gsub!(" ", "_")
      tablename.downcase!
      return tablename
    end

    def delimiter
      return options[:delimiter]
    end

    # this didn't work - wonder why? Need to check on the reason behind it!!
    # def sql_helper_options
    #   return @sql_helper_options# = {tablename: tablename, filename: filename, delimiter: delimiter}
    # end
    # binding.pry
    # @mysql_helper = CsvImportAnalyzer::Helper::MysqlQueryHelper.new(@sql_helper_options)
    # @pg_helper = CsvImportAnalyzer::Helper::PgQueryHelper.new(@sql_helper_options)

    def mysql_helper
      @mysql_helper
    end

    def pg_helper
      @pg_helper
    end

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
      return create_query, import_query
    end

    private

    def build_query_for_datatype(header, datatype)
      query = {}
      databases.each do |db|
        if db == :mysql
          query[db] = mysql_helper.form_query_for_datatype(header, datatype)
        else
          query[db] = pg_helper.form_query_for_datatype(header, datatype)
        end
      end
      unless nullable.include?(header)
        query.keys.each do |db|
          query[db] << " not null"
        end
      end
      return query
    end

    def prepare_import_csv
      databases.each do |db|
        if db == :mysql
          import_query[db] = mysql_helper.import_csv
        elsif db == :pg
          import_query[db] = pg_helper.import_csv
        end
      end
    end

    def prepare_sql_statements
      databases.each do |db|
        create_query[db][0] = create_query[db].first + " " + create_query[db][1]
        create_query[db].delete_at(1)
        create_query[db] = create_query[db].join(", ")
        create_query[db] << ");"
      end
    end

  end
end

#Testing
# args = {}
# args[:options] = {:delimiter => ",", :chunk => 20, :filename => "/home/avinash/Desktop/csv-import-analyzer/lib/csv-import-analyzer/sampleTab"}
# args[:column_datatypes] = {:year_id=>:int, :make_id=>:string, :model_id=>:string, :description_id=>:string, :price_id=>:float}
# args[:nullable] = [:description_id]
# query = CsvImportAnalyzer::SqlQueryBuilder.new(args)
# puts query.generate_query