# check_bounds = CsvImportAnalyzer::Helper::CsvCheckBounds.new({:year_id=>:int, :make_id=>:string, :model_id=>:string, :description_id=>:string, :price_id=>:float}, 
#   {:delimiter => ",", :chunk => 20, :filename => "/home/avinash/Desktop/csv-import-analyzer/lib/csv-import-analyzer/sampleTab.csv"})
# check_bounds.get_min_max_values