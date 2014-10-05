# require 'spec_helper'

describe CsvImportAnalyzer do
  include CsvImportAnalyzer
  it "return invalid file as file not found" do
    expect(CsvImportAnalyzer.process("sample.csv")).to be_instance_of(FileNotFound)
  end
  it "processes a valid file" do
    expect(CsvImportAnalyzer.process($sample_csv_path)).not_to be_instance_of(FileNotFound)
  end
end
