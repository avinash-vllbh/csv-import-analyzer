require 'pry'
module CsvImportAnalyzer
  module Helper
    class MysqlQueryHelper

      attr_accessor :tablename, :filename, :delimiter

      def initialize(args)
        # binding.pry
        @tablename = args[:tablename]
        @filename = args[:filename]
        @delimiter = args[:delimiter]
      end
    
      def form_query_for_datatype(header, datatype)
        if datatype == :string
          # binding.pry

          return header.to_s + " varachar(255)"
        else
          return header.to_s + " " + datatype.to_s
        end
      end

      def import_csv
        import_statement = "LOAD DATA INFILE #{filename} INTO TABLE #{tablename} "+
              "FIELDS TERMINATED BY '#{delimiter}' "+
              "ENCLOSED BY '\"' "+
              "LINES TERMINATED BY '\\n' "+
              "IGNORE 1 LINES;"
      end

    end
  end
end

# if datatype == :string
#   query[:pg] = header.to_s+" varachar(255)"
#   query[:mysql] = header.to_s+" varachar(255)"
# else
#   query[:pg] = header.to_s + " " + datatype.to_s
#   query[:mysql] = header.to_s + " " + datatype.to_s
# end