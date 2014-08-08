# require 'spec_helper'

# CsvImportAnalyzer.process("sampleTab.csv", {:metadata_output => true})


describe CsvImportAnalyzer do
  include CsvImportAnalyzer
  it 'should return invalid file as file not found' do
    expect(CsvImportAnalyzer.process("sample.csv")).to be_instance_of(FileNotFound)
  end
  it 'should be able to process a valid file' do
    expect(CsvImportAnalyzer.process($sample_csv_path)).not_to be_instance_of(FileNotFound)
  end
end