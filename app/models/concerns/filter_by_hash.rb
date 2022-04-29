module FilterByHash
  extend ActiveSupport::Concern

  included do
    scope :filter_by_hash, lambda { |hash, logic=:and|
      chain = ActiveRecord::Relation.new(self.instance_variable_get(:@klass))
      current_logic = :and
      hash.each_pair do |key, value|
        key = key[/[a-z0-9_]+/, 0]
        next if key == ''
        case value
        when Numeric
          sql = "#{key}=#{value}"
        when Array
          sql = sanitize_sql_for_conditions(['?', value])
          sql = "#{key} IN (#{sql})"
        when String
          value = sanitize_sql_like value
          value = sanitize_sql_for_conditions(['?', value])[1..-2]
          next if value == ''
          sql = "#{key} ILIKE '%#{value}%'"
        when FalseClass
          sql = "#{key}=FALSE"
        when TrueClass
          sql = "#{key}=TRUE"
        when NilClass
          sql = "#{key} IS NULL"
        when Range
          if value.first.is_a? Numeric
            sql = "#{key} BETWEEN #{value.first} AND #{value.last}"
          elsif value.first.class.in?([ActiveSupport::TimeWithZone, Time, DateTime])
            sql = "#{key} BETWEEN '#{I18n.l(value.first.localtime(0), format: :postgres)}' AND "+
                                 "'#{I18n.l(value.last.localtime(0),  format: :postgres)}'"
          elsif value.first.is_a?(Date)
            sql = "#{key} BETWEEN '#{I18n.l(value.first, format: :postgres)}' AND "+
                                 "'#{I18n.l(value.last,  format: :postgres)}'"
          end
        end

        if current_logic == :and
          chain = chain.where(sql)
        elsif current_logic == :or
          chain = chain.or(Account.where(sql))
        end
        current_logic = logic
      end
      return chain
    }
  end
end
