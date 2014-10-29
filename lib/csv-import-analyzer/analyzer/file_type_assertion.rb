# file_type_assertion.rb
require 'pry'
module CsvImportAnalyzer
  module Analyzer
    class FileTypeAssertion

      def check_file_type(filename)
        extension = File.absolute_path(filename).split(".").last
        if extension == "csv"
          Analyzer::FileTypeAssertion.new("sampleTab.csv")
        #Try adding support for non csv files - xlsx, xls in future
        elsif extension == "xlsx"
          puts "xlsx"
        else
          # return UnsupportedFileFormat.new
        end
      end

      def convert_excel_to_csv

      end

    end
  end
end