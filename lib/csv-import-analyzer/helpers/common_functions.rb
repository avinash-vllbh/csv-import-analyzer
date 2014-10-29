module CsvImportAnalyzer
  module Helper
    ###
    # To determine if a certain field in the dataset of null type
    # returns a boolean of it's either null or not
    ###
    def null_like?(value)
      if ["NULL", "Null", "NUll", "NULl", "null", nil, "", "NAN", "\\N"].include?(value)
        true
      else
        false
      end
    end
  end
end