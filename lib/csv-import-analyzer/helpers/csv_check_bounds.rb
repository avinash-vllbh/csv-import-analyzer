require 'smarter_csv'
require 'pry'

module CsvImportAnalyzer
  module Helper
    class CsvCheckBounds
      attr_accessor :min_max_bounds, :csv_column_datatypes, :options, :nullable

      def initialize(datatypes, options)
        self.csv_column_datatypes = datatypes
        self.options = options
        self.min_max_bounds = {}
        self.nullable = []

      end

      def filename
        return options[:filename]
      end
      def chunk_size
        return options[:chunk_size]
      end
      def delimiter
        return options[:delimiter]
      end

      def get_min_max_values
        SmarterCSV.process(filename, {:col_sep => delimiter, :chunk_size => chunk_size, 
        :remove_empty_values => false, :remove_zero_values => false}) do |chunk|
          chunk.each do |row|
            puts row
            row.each do |key, value|
              unless value.nil? or value == ""
                process_min_max_for_column(key, value)
              else             
                nullable.push(key) unless nullable.include?(key)
              end
            end
          end
        end
        # puts csv_column_datatypes
        # puts nullable
        # puts min_max_bounds
      end

      private

      def process_min_max_for_column(key, value)
        if min_max_bounds[key].nil?
          # binding.pry
          unless csv_column_datatypes[key] == :string
            min_max_bounds[key] = {:min => value, :max => value}
          else
            min_max_bounds[key] = {:min => value.length, :max => 0}
          end
        end
        add_bounds(key, value)
      end

      def add_bounds(key, value)
        if csv_column_datatypes[key] == :string
          min_max_bounds[key][:min] = value.length if value.length < min_max_bounds[key][:min]
          min_max_bounds[key][:max] = value.length if value.length > min_max_bounds[key][:max]
        else
          min_max_bounds[key][:min] = value if value < min_max_bounds[key][:min]
          min_max_bounds[key][:max] = value if value > min_max_bounds[key][:max]
        end
      end

    end
  end
end

check_bounds = CsvImportAnalyzer::Helper::CsvCheckBounds.new({:year_id=>:int, :make_id=>:string, :model_id=>:string, :description_id=>:string, :price_id=>:float}, 
  {:delimiter => ",", :chunk => 20, :filename => "/home/avinash/Desktop/csv-import-analyzer/lib/csv-import-analyzer/sampleTab.csv"})
check_bounds.get_min_max_values