require 'spec_helper'

describe CsvImportAnalyzer::DelimiterIdentifier do
  it 'should return comma as delimiter' do
    expect(CsvImportAnalyzer::DelimiterIdentifier.identify_delimiter($sample_csv_path)).to eq(",")
  end
end