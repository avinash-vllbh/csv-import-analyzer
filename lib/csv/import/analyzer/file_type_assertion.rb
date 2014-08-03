# file_type_assertion.rb
require 'pry'
module Analyzer
  class FileTypeAssertion

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def check_file_type

    end

    def convert_excel_to_csv

    end

  end
end

hi = Analyzer::FileTypeAssertion.new("avinash")
hi.test