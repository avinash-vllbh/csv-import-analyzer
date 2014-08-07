module CsvImportAnalyzer
  module Helper

    extend self

    def null_like?(value)
      if ["NULL", "Null", "NUll", "NULl", "null", nil, "", "NAN", "\\N"].include?(value)
        true
      else
        false
      end
    end
  end
end