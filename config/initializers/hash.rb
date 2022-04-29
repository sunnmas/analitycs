def snake_to_human val
  val&.gsub('_', ' ')&.upcase
end

class Hash
  def to_html(alphabetical: true, sequence: nil)
    result = '<table>'
    if sequence
      keys = sequence
    else
      keys = self.keys
      keys.sort! if alphabetical
    end
    keys.map!{|key| key.to_s}

    keys.each do |key|
      value = self[key].present? ? self[key] : self[key.to_sym]
      value = value&.gsub("\r\n", '<br>')&.gsub("\n", '<br>')&.gsub("\r", '<br>') if value.is_a? String
      result << "<tr><th>#{snake_to_human(key)}</th><td>#{value}</td></tr>"
    end
    result << '</table>'
  end

  def all_values_blank?
    self.keys.all?{ |key| self[key].blank? }
  end
end
