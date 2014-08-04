require 'pry'
require_relative "csv-import-analyzer/analyzer"
module CSVImportAnalyzer
  # To identify the methods  as class methods
  extend self
  def process(filename, options = {})
    if File::exists?(filename)
      CsvImportAnalyzer::Analyzer.process(File.absolute_path(filename), options)
    else
      # FileNotFound.new
    end
  end
end
CSVImportAnalyzer.process("sampleTab.csv", {:metadata_output => true})