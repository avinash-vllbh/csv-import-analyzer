# require 'spec_helper'

class DummyClass
end

describe '#identify_delimiter' do
  
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::DelimiterIdentifier)
  end

  context 'unable to determine the delimiter' do
  
    it 'return invalid input when the input is neither string nor array' do
      expect(@dummy_class.identify_delimiter(3)).to be_instance_of(InvalidInput)
    end

    it 'returns file not found when the input string is not a valid file' do
      expect(@dummy_class.identify_delimiter("test")).to be_instance_of(FileNotFound)
    end

  end

  context 'finds the delimiter when the input is a file' do
    
    it 'returns a comma as the delimiter for sample_csv file' do
      expect(@dummy_class.identify_delimiter($sample_csv_path)).to eq(",")
    end
    
    it 'returns a semicolon as the the delimiter for sample_ssv file' do
      expect(@dummy_class.identify_delimiter($sample_ssv_path)).to eq(";")
    end

  end

  context 'finds the delimiter when the input is an array' do
    let(:sample) {['1999;Chevy;"Venture ""Extended Edition""";"";4900.00','1999;\'Chevy\';"Venture ""Extended Edition; Very Large""";;5000.00']}
    it 'returns a semicolon as the delimiter for sample array input' do
      expect(@dummy_class.identify_delimiter(sample)).to eq(";")
    end
  end
end

describe '#return_plausible_delimiter' do
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::DelimiterIdentifier)
  end

  context 'identifies delimiter' do
    it 'returns comma as the delimiter by default' do
      expect(@dummy_class.return_plausible_delimiter).to eq(",")
    end

    it 'returns semicolon as the delimiter for sample delimiter_count' do
      @dummy_class.stub(:delimiter_count) { Hash[","=>15, ";"=>16, "\t"=>0, "|"=>0] }
      expect(@dummy_class.return_plausible_delimiter).to eq(";")
    end
  end  
end