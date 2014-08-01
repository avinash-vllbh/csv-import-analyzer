#csv-import-analyzer.rb
require_relative "csv/import/analyzer"
module CSVImportAnalyzer
  # To identify the methods  as class methods
  extend self
  def process(name)
    Csv::Import::Analyzer.process(name)
  end
end
CSVImportAnalyzer.process("avinash")
# CSVImportAnalyzer.test