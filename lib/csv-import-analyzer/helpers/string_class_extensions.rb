class String
  
  ###
  # Monkey patch string class to find the count of needle in haystack
  # haystack is self => string in itself
  # needle could be anything
  # E.g.
  # "hello, how, are, you".substr_count(",") => 3
  ###
  def substr_count(needle)
    needle = "\\#{needle}" if(needle == '|') # To escape inside regex
    self.scan(/(#{needle})/).size
  end
end
