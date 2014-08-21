# require 'spec_helper'
class DummyClass
end
describe '#form_query_for_datatype' do
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::MysqlQueryHelper)
  end
  context 'expected arguments are not set' do
    let(:args) {Hash[:header => :test]}
    let(:args1) {Hash[:datatype, :test]}
    it ' returns missing arguments error' do
      expect(@dummy_class.form_query_for_datatype(args)).to be_instance_of(MissingRequiredArgumentsError)
    end
    it 'returns invalid if set to nil' do
      expect(@dummy_class.form_query_for_datatype(args1)).to be_instance_of(MissingRequiredArgumentsError)
    end
  end

  context 'expected arguments are set' do
    let(:args) {Hash[:header => :test, :datatype => :string]}
    let(:args1) {Hash[:header => :test, :datatype => :integer]}
    it 'returns expected sql query for string' do
      expect(@dummy_class.form_query_for_datatype(args)).to eq("test varchar(255)")
    end
    it 'returns expected sql query for numeric' do
      expect(@dummy_class.form_query_for_datatype(args1)).to eq("test integer")
    end
  end

end
describe '#import_csv' do
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::MysqlQueryHelper)
  end
  context 'expected arguments are not set' do
    let(:args) {Hash[:tablename => "test", :delimiter => ","]}
    let(:args1) {Hash[:filename => "test"]}
    it ' return SqlQueryErrror' do
      expect(@dummy_class.import_csv(args)).to be_instance_of(MissingRequiredArgumentsError)
    end
    it 'should return SqlQueryErrror' do
      expect(@dummy_class.import_csv(args1)).to be_instance_of(MissingRequiredArgumentsError)
    end
  end

  context 'expected arguments are set' do
    let(:args) {Hash[:tablename => "test", :delimiter => ",", :filename => "sample.csv"]}
    it 'returns expected import query' do
      expect(@dummy_class.import_csv(args)).to eq("LOAD DATA INFILE sample.csv INTO TABLE test FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\\n' IGNORE 1 LINES;")
    end
  end
end