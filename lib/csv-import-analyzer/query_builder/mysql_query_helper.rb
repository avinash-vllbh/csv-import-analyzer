require_relative "../helpers/errors"
require 'pry'
module CsvImportAnalyzer
  module MysqlQueryHelper
  
    def form_query_for_datatype(args)
      unless args[:datatype].nil? || args[:header].nil?
        if args[:datatype] == :string
          return args[:header].to_s + " varchar(255)"
        else
          return args[:header].to_s + " " + args[:datatype].to_s
        end
      else
        MissingRequiredArgumentsError.new("Required arguments missing for form_query_for_datatype")
      end
    end

    def import_csv(args)
      unless args[:tablename].nil? || args[:filename].nil? || args[:delimiter].nil?
        import_statement = "LOAD DATA INFILE #{args[:filename]} INTO TABLE #{args[:tablename]} "+
              "FIELDS TERMINATED BY '#{args[:delimiter]}' "+
              "ENCLOSED BY '\"' "+
              "LINES TERMINATED BY '\\n' "+
              "IGNORE 1 LINES;"
      else
        MissingRequiredArgumentsError.new("Required arguments missing for import_csv")
      end
    end

  end
end