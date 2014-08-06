module CsvImportAnalyzer
  module Helper
    class PgQueryHelper
      attr_accessor :tablename, :filename, :delimiter

      def initialize(args)
        @tablename = args[:tablename]
        @filename = args[:filename]
        @delimiter = args[:delimiter]
      end
    
      def form_query_for_datatype(header, datatype)
        if datatype == :string
          return header.to_s + " varachar(255)"
        else
          return header.to_s + " " + datatype.to_s
        end
      end

      def import_csv
        pg_import_statement = "COPY #{tablename} FROM '#{filename}' HEADER DELIMITER '#{delimiter}' CSV NULL AS 'NULL';"
      end

    end
  end
end