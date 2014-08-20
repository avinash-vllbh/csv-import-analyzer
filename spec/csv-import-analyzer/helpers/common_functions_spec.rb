# require 'spec_helper'

class DummyClass
end

describe 'null_like?' do
  
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::Helper)
  end

  context 'when called on null like objects' do
    it 'returns the string as null' do
      expect(@dummy_class.null_like?('NULL')).to eq(true)
    end
  end

  context 'when called on non-null objects' do
    it 'returns the string as not null' do
      expect(@dummy_class.null_like?('Hello')).to eq(false)
    end
  end
end