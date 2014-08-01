require_relative "analyzer/version"
require "smarter_csv"

module Csv
  module Import
    module Analyzer
      def self.options
        @options ||= {
          :metadata_output => true,
          :min_max_values => true
        }
      end
      def self.process(name)
        puts options
        test = SmarterCSV.process('/home/avinash/Desktop/process_csv/samples/sampleTab.csv')
        puts test
      end
    end
  end
end
