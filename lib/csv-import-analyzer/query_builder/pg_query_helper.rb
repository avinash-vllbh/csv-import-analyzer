require_relative "../helpers/errors"
module CsvImportAnalyzer
  module PgQueryHelper

    # attr_accessor :tablename, :filename, :delimiter

    # def initialize(args)
    #   @tablename = args[:tablename]
    #   @filename = args[:filename]
    #   @delimiter = args[:delimiter]
    # end
  
    def form_query_for_datatype(args)
      unless args[:datatype].nil? && args[:header].nil?
        if args[:datatype] == :string
          return args[:header].to_s + " varachar(255)"
        else
          return args[:header].to_s + " " + args[:datatype].to_s
        end
      else
        SqlQueryError.new
      end
    end

    def import_csv(args)
      unless args[:tablename] && args[:filename] && args[:delimiter]
        pg_import_statement = "COPY #{args["tablename"]} FROM '#{args["filename"]}' HEADER DELIMITER '#{args["delimiter"]}' CSV NULL AS 'NULL';"
      else
        SqlQueryError.new
      end
    end

  end
end