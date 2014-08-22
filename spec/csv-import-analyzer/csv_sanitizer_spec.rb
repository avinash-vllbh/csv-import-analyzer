# require 'spec_helper'

describe CsvImportAnalyzer::CsvSanitizer do
  let (:csv_sanitizer) { CsvImportAnalyzer::CsvSanitizer.new }
  # let (:test) {["t1","t2","",nil,"t3"]}
  # let (:res) {["t1","t2","NULL","NULL","t3"]}
  it 'should handle file not found issue' do
    expect(csv_sanitizer.process("sample.csv", options = {})).to be_instance_of(FileNotFound)
  end
  let (:test) {"\"t1\", 't2', \"t3\""}
  let (:res) {"\"t1\", \"t2\", \"t3\""}
  it 'should replace single quotes to double' do
    expect(csv_sanitizer.send(:replace_line_single_quotes, test, ",")).to eq(res)
  end
  context 'testing private methods' do
    let (:test) {["t1","t2","",nil,"t3"]}
    let (:res) {["t1","t2","NULL","NULL","t3"]}
    it 'should replace null values' do
      expect(csv_sanitizer.send(:replace_null_values, test)).to eq(res)
    end
  end

end