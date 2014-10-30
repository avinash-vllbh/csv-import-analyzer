require_relative "../helpers/string_class_extensions"
module CsvImportAnalyzer
  module DelimiterIdentifier

    ###
    # Types of delimiters that the gem has to lookout for.
    # Could be changed in future or to custom delimiters
    # returns a @delimiter instance variable array
    ###
    def delimiter
      @delimiter ||= [",", ";", "\t", "|"]
    end

    ###
    # Routine to intialize the delimiter_count hash with the delimiters defined above with a base count of 0
    # Returns @delimiter_count instance variable
    ###
    def delimiter_count
      @delimiter_count ||= Hash[delimiter.map {|v| [v,0]}]
      @delimiter_count
    end

    ###
    # Method to analyze input data and determine delimiter
    # Input can be either a csv file or even a array of strings
    # returns delimiter
    ###
    def identify_delimiter(filename_or_sample)
      #filename_or_sample input can be either a File or an Array or a string - Return delimiter for File or an Array of strings (if found)
      if filename_or_sample.class == String
        if File::exists?(filename_or_sample)
          current_line_number = 0
          File.foreach(filename_or_sample) do |line|
            count_occurances_delimiter(line)
            current_line_number += 1
            if current_line_number > 3
              break
            end
          end
        else
          # count_occurances_delimiter(filename_or_sample)
          return FileNotFound.new
        end
        return_plausible_delimiter
      elsif filename_or_sample.class == Array
        filename_or_sample.each do |line|
          count_occurances_delimiter(line)
        end
        return_plausible_delimiter
      else
        InvalidInput.new
      end
    end

    private

    def getting_contents_of_quoted_values(input)
      #return a join of all the strings inside quotes inside a line
      input.scan(/".*?"/).join
    end

    ###
    # Find the count of delimiter occurances in a line
    # CSV files can have delimiters escaped between quotes
    # valid count = total_count - delimiters inside quotes
    ###
    def count_occurances_delimiter(line)
      delimiter_count.keys.each do |key|
        #Count the occurances of delimiter in a line
        total_count_delimiter = line.substr_count(key)
        #count the occurances of delimiter between quotes inside a line to disregard them
        quoted_delimiter_count = getting_contents_of_quoted_values(line).substr_count(key)
        delimiter_count[key] += total_count_delimiter - quoted_delimiter_count
      end
    end

    ###
    # Plausible delimiter would be the one i.e. of most occurance of the set of rows
    ###
    def return_plausible_delimiter
      return delimiter_count.key(delimiter_count.values.max)
    end

  end
end
