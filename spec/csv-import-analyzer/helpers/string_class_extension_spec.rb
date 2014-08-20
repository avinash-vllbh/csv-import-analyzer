# require 'spec_helper'

describe 'substr_count' do
  context 'different possible delimiters' do
    it 'returns count of commas as delimiter in a string' do
      expect("hello, hi, how, are you?".substr_count(",")).to eq(3)
    end
    it 'returns count of semi-colons as delimiter in a string' do
      expect("hello; hi, how, are you?".substr_count(";")).to eq(1)
    end
    it 'returns count of pipe as delimiter in a string' do
      expect("hello, hi| how| are you?".substr_count("|")).to eq(2)
    end
    it 'returns count of tab as delimiter in a string' do
      expect("hello\thi\thow| are you?".substr_count("\t")).to eq(2)
    end
  end
end