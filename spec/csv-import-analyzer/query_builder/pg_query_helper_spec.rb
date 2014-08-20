# require 'spec_helper'
class DummyClass
end
describe 'form_query_for_datatype' do
  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(CsvImportAnalyzer::PgQueryHelper)
  end
  context 'expected arguments are set' do
    let(:args) {Hash["header", "test"]}
    it 'should return SqlQueryErrror' do

    end
  end

  context 'expected arguments are not set' do
    
    it ''
  end

end