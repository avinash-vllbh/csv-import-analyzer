# require 'spec_helper'

describe CsvImportAnalyzer::CsvSanitizer do
  # May be I should really use subject here
  # why?
  let (:csv_sanitizer) { CsvImportAnalyzer::CsvSanitizer.new }
  it "handles file not found issue - when given a invalid file" do
    expect(csv_sanitizer.process("sample.csv", options = {})).to be_instance_of(FileNotFound)
  end
  
  # Testing private methods - Although one shouldn't really have to test private methods
  # Testing here to make sure the private methods are doing what they are supposed to
  context "testing private methods" do
    let (:test) {"\"t1\", 't2', \"t3\""}
    let (:res) {"\"t1\", \"t2\", \"t3\""}
    xit "replaces single quotes to double quotes" do
      binding.pry
      expect(csv_sanitizer.send(:replace_line_single_quotes, test, ",")).to eq(res)
    end
    let (:test) {["t1","t2","",nil,"t3"]}
    let (:res) {["t1","t2","NULL","NULL","t3"]}
    it "replaces nil or empty values to NULL" do
      expect(csv_sanitizer.send(:replace_null_values, test)).to eq(res)
    end
  end

end
