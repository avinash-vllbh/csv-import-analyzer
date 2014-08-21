# require 'spec_helper'
require 'date'
class DummyClass
end

describe '#validate_field' do
  
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::DatatypeValidator)
  end

  context 'knows what an integer looks like' do
    
    it 'returns Fixnum type as integer' do
      expect(@dummy_class.validate_field(10)).to eq("int")
    end
    it 'returns Fixnum type with spaces as integer' do
      expect(@dummy_class.validate_field(' 10 ')).to eq("int")
    end
    it 'returns Fixnum type with comma as integer' do
      expect(@dummy_class.validate_field('1,000')).to eq("int")
    end
    it 'returns Fixnum type negative number as integer' do
      expect(@dummy_class.validate_field(-3)).to eq("int")
    end

  end

  context 'knows what an Float looks like' do
    
    it 'returns Float type as float' do
      expect(@dummy_class.validate_field(10.0)).to eq("float")
    end
    it 'returns Float type with spaces as float' do
      expect(@dummy_class.validate_field(' 10.01 ')).to eq("float")
    end
    it 'returns Float type with comma as float' do
      expect(@dummy_class.validate_field('1,000.01')).to eq("float")
    end
    it 'returns Float type negative number as float' do
      expect(@dummy_class.validate_field(-3.3)).to eq("float")
    end

  end
  
  context 'it knows what a date looks like' do
    it 'return true for a valid date type - dd/mm/yyyy' do
      expect(@dummy_class.validate_field('31/12/2014')).to eq("date")
    end
    it 'return true for a valid date type - mm/dd/yyyy' do
      expect(@dummy_class.validate_field('12/31/2014')).to eq("date")
    end
    it 'return true for a valid date type - mm-dd-yyyy' do
      expect(@dummy_class.validate_field('12-31-2014')).to eq("date")
    end
    it 'return true for a valid date type - mm dd yyyy' do
      expect(@dummy_class.validate_field('12 31 2014')).to eq("date")
    end
  end 

  context 'it knows what a String looks like' do
    it 'default to String type' do
      expect(@dummy_class.validate_field("100 testingNow:)")).to eq("string")
    end
    it 'returns String type as string' do
      expect(@dummy_class.validate_field("Hello")).to eq("string")
    end
  end
end