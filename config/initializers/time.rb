class Time
  def self.yesterday(now = nil)
    now = Time.now if now.blank?
    t1 = now.beginning_of_day-1.day
    t2 = (now-1.day).end_of_day
    t1..t2
  end

  def self.last_week(now = nil)
    now = Time.now if now.blank?
    t1 = now.beginning_of_week - 7.days
    t2 = now.end_of_week - 7.days
    t1..t2
  end

  def self.last_month(now = nil)
    now = Time.now if now.blank?
    t1 = (now.beginning_of_month - 1.month).beginning_of_day
    t2 = (now.end_of_month - 1.month).end_of_day
    t1..t2
  end
end
