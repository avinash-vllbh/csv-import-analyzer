module CsvImportAnalyzer
  module Helper
    class DatatypeValidator

      def validate_field(content)
        return get_datatype(content)
      end

      private
      ###
      # To check for pattern of Date format after Date.parse is successfull
      # Date.parse(3000) => true which is not supposed to be true
      ###
      def datetime_pattern(field)
        pattern1 = field.scan(/[0-9]\//)
        pattern2 = field.scan(/[0-9]\-/)
        pattern3 = field.scan(/[0-9] /)
        pattern4 = field.scan(/[0-9] [A-Z][a-z][a-z] [0-9]|[0-9]-[A-Z][a-z][a-z]-[0-9]|[0-9] [a-z][a-z][a-z] [0-9]|[0-9]-[a-z][a-z][a-z]-[0-9]/)
        if(pattern1.size == 2||pattern2.size == 2||pattern3.size == 2||pattern4.size != 0)
          return true
        else
          return false
        end
      end
      ###
      #To determine the data-type of an input field
      ###
      def get_datatype(field)
        #Remove if field has any comma's for int and float rep
        if field != nil && field.class == String
          num = field.gsub(/,/,'')
        else
          num = field
        end
        if(Integer(num) rescue false)
          if num.class == Float
            return "float"
          end
          return "int"
        elsif(Float(num) rescue false)
          return "float"
        elsif(Date.parse(field) or Date.strptime(field, '%m/%d/%Y') or Date.strptime(field, '%m-%d-%Y') or Date.strptime(field, '%m %d %Y') rescue false)
          if datetime_pattern(field)
            if field =~ /:/ # To check if the field contains any pattern for Hours:minutes
              return "datetime"
            else
              return "date"
            end
          end
        end
        return "string"
      end

    end
  end
end