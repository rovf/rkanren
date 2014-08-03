  # Similar to strip!, but always returnes the string (strip!
  # returns nil, if the string was not changed)
  class String
    def striP!
      strip!
      self
    end
  end
