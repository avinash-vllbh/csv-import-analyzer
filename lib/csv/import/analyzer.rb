require_relative "analyzer/version"
require "smarter_csv"

module Csv
  module Import
    module Analyzer
      # def initialize(options)
      #   options = defaults.merge(options)
      # end
      def self.defaults
        {
          :metadata_output => nil, 
          :processed_input => nil, 
          :unique => 10, 
          :chunk => 20, 
          :skip => 0, 
          :database => nil, 
          :quote_convert => true, 
          :replace_nulls => true
        }
      end
      def self.options
        @options ||= {
          :metadata_output => true,
          :min_max_values => true
        }
      end
      def self.process(name)
        puts defaults.merge(options)
        test = SmarterCSV.process('/home/avinash/Desktop/process_csv/samples/sampleTab.csv')
        puts test
      end
    end
  end
end
