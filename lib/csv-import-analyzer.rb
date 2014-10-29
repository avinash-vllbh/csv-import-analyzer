require_relative "csv-import-analyzer/csv_sanitizer"
require_relative "csv-import-analyzer/helpers/errors"
module CsvImportAnalyzer
  # To identify the methods in the module as class methods
  extend self

  ###
  # main public interface to the library
  # makes sure that the file exists and
  # passes the file and any additional options given to CsvSanitizer
  # returns FileNotFound if given file is invalid
  ###
  def process(filename, options = {})
    if File::exist?(filename)
      CsvImportAnalyzer::CsvSanitizer.new().process(File.absolute_path(filename), options)
    else
      FileNotFound.new
    end
  end
end
