require 'pry'
require_relative "csv-import-analyzer/csv_sanitizer"
require_relative "csv-import-analyzer/helpers/errors"
module CsvImportAnalyzer
  # To identify the methods in the module as class methods
  extend self

  def process(filename, options = {})
    if File::exist?(filename)
      CsvImportAnalyzer::CsvSanitizer.new().process(File.absolute_path(filename), options)
    else
      FileNotFound.new
    end
  end
end
