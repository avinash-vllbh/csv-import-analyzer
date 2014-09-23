# require 'spec_helper'

require 'pry'
describe CsvImportAnalyzer::CsvSanitizer do
  let (:csv_sanitizer) { CsvImportAnalyzer::CsvSanitizer.new }
  it 'should handle file not found issue' do
    expect(csv_sanitizer.process("sample.csv", options = {})).to be_instance_of(FileNotFound)
  end
  
  # Testing private methods - Although one shouldn't really have to test private methods
  # Testing here to make sure the private methods are doing what they are supposed to
  context 'testing private methods' do
    let (:test) {"\"t1\", 't2', \"t3\""}
    let (:res) {"\"t1\", \"t2\", \"t3\""}
    xit 'should replace single quotes to double' do
      binding.pry
      expect(csv_sanitizer.send(:replace_line_single_quotes, test, ",")).to eq(res)
    end
    let (:test) {["t1","t2","",nil,"t3"]}
    let (:res) {["t1","t2","NULL","NULL","t3"]}
    it 'should replace null values' do
      expect(csv_sanitizer.send(:replace_null_values, test)).to eq(res)
    end
  end

end
