require 'pry'
module CsvImportAnalyzer
  class MetadataAnalysis
    def initialize(options)
      @options = options
    end

    def options
      @options
    end

    def metadata_print
      binding.pry
      if options[:out_format] = :json

      else

      end
    end
    def json_analysis

    end
    def csv_analysis

    end
  end
end