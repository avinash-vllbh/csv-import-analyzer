#require spec_helper.rb
describe CsvImportAnalyzer::CsvCheckBounds do
  describe '#get_min_max_values' do
    let(:options) {Hash[filename: "sample"]}
    # before(:each) do
    # end
    context 'when not initialized right' do
      it 'will fail gracefully if filename is nil' do
        @csv_check_bounds = CsvImportAnalyzer::CsvCheckBounds.new
        expect(@csv_check_bounds.get_min_max_values).to be_instance_of(MissingRequiredArguments)
      end
      it 'returns FileNotFound error if file is not found' do
        @csv_check_bounds = CsvImportAnalyzer::CsvCheckBounds.new(options)

        expect(@csv_check_bounds.get_min_max_values).to be_instance_of(FileNotFound)
      end
    end
  end
end