require 'pry'
require_relative "csv-import-analyzer/csv_sanitizer"
require_relative "csv-import-analyzer/helpers/error_handler"
module CSVImportAnalyzer
  # To identify the methods in the module as class methods
  extend self
  def process(filename, options = {})
    if File::exists?(filename)
      CsvImportAnalyzer::CsvSanitizer.new().process(File.absolute_path(filename), options)
    else
      # FileNotFound.new
    end
  end
end
CSVImportAnalyzer.process("sampleTab.csv", {:metadata_output => true})