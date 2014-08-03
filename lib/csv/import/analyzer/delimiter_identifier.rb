class String
  #Extending string class to return the count of substr inside a string
  def substr_count(needle)
    needle = "\\#{needle}" if(needle == '|') # To escape inside regex
    self.scan(/(#{needle})/).size
  end
end
module Analyzer
  module DelimiterIdentifier
    extend self
    
    @delimiter = {"," => 0, ";" => 0, "\t" => 0, "|" => 0}

    def delimiter
      @delimiter
    end

    def getting_contents_of_quoted_values(input)
      #return a join of all the strings inside quotes inside a line
      input.scan(/".*?"/).join
    end

    def count_occurances_delimiter(line)
      delimiter.keys.each do |key|
        #Count the occurances of delimiter in a line
        total_count_delimiter = line.substr_count(key)
        #count the occurances of delimiter between quotes inside a line
        quoted_delimiter_count = getting_contents_of_quoted_values(line).substr_count(key)

        delimiter[key] += total_count_delimiter - quoted_delimiter_count
      end
    end

    def return_plausible_delimiter
      delimiter.each { |key, value| 
        return key if value = delimiter.values.max
      }
    end

    def identify_delimiter(filename_or_sample)
      #filename_or_sample input can be either a File or an Array or a string - Return delimiter for anything (if found)
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
          count_occurances_delimiter(line)
          # return FileNotFound.new
        end
      elsif filename_or_sample.class == Array
        filename_or_sample.each do |line|
          count_occurances_delimiter(line)
        end
      else
        return InvalidInput.new
      end
      return return_plausible_delimiter
    end

  end
end
puts Analyzer::DelimiterIdentifier.identify_delimiter("sampleTab.csv")