require 'pry'
class String
  #Extending string class to return the count of substr inside a string
  def substr_count(needle)
    needle = "\\#{needle}" if(needle == '|') # To escape inside regex
    self.scan(/(#{needle})/).size
  end
end