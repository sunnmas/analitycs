class String
  def to_bool
    case self.downcase
    when  'false', '0'
      false
    when 'true', '1'
      true
    else
      nil
    end
  end
end

class TrueClass
  def to_bool
    true
  end
end

class FalseClass
  def to_bool
    false
  end
end
