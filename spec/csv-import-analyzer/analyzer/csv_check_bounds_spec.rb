#require spec_helper.rb

describe CsvImportAnalyzer::CsvCheckBounds do

  describe "#get_min_max_values" do
    context "when not initialized right" do
      let(:options) {Hash[filename: "sample", chunk_size: 200, delimiter: ",", unique: 2]}
      
      it "will fail gracefully if filename is nil" do
        @csv_check_bounds = CsvImportAnalyzer::CsvCheckBounds.new
        expect(@csv_check_bounds.get_min_max_values).to be_instance_of(MissingRequiredArguments)
      end
      
      it "returns FileNotFound error if file is not found" do
        @csv_check_bounds = CsvImportAnalyzer::CsvCheckBounds.new(options)
        expect(@csv_check_bounds.get_min_max_values).to be_instance_of(FileNotFound)
      end
    end

    context "when initialized right" do
      let(:options) {Hash[filename: $sample_csv_path, chunk_size: 200, delimiter: ",", unique: 2, csv_column_datatypes: {:year_id => :int, :make_id => :string, :model_id => :string, :description_id => :string, :price_id => :float}]}
      before(:each) do
        @csv_check_bounds = CsvImportAnalyzer::CsvCheckBounds.new(options)
      end
    
      it "returns a Hash" do
        expect(@csv_check_bounds.get_min_max_values).to be_an_instance_of(Hash)
      end
    
      it "returns correct min & max values for integer type" do
        result = @csv_check_bounds.get_min_max_values
        expect(result[:min_max][:year_id][:min]).to eq(1996)
        expect(result[:min_max][:year_id][:max]).to eq(1999)
      end
    
      it "returns correct min & max lengths for string type" do
        result = @csv_check_bounds.get_min_max_values
        expect(result[:min_max][:make_id][:min]).to eq(4)
        expect(result[:min_max][:make_id][:max]).to eq(7)
      end
    end
  end
end