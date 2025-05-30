class Pharmacy < ApplicationRecord
  has_many :pharmacy_opening_hours, dependent: :destroy
  has_many :masks, dependent: :destroy
  has_many :orders

  attribute :cash_balance, :float

  validates :name, presence: true
  validates :cash_balance, numericality: { greater_than_or_equal_to: 0 }

  def opening_hours_text
    hours = pharmacy_opening_hours.order(:day_of_week, :open_time)
    merged = PharmacyOpeningHoursMerger.call(hours)[id] || []
    return "" if merged.empty?
  
    # Group by time range + overnight
    grouped = merged.group_by { |h| "#{h[:open_time]}-#{h[:close_time]}-#{h[:overnight]}" }
  
    result = grouped.map do |key, group_hours|
      days = group_hours.map { |h| h[:day_of_week] == 0 ? 7 : h[:day_of_week] }.uniq.sort
      time_range = key.split('-')[0..1].join(' - ')
      {
        days: days,
        text: "#{format_days(days)} #{time_range}"
      }
    end
  
    # 排序：平日優先，週末在後
    result.sort_by { |r| r[:days].any? { |d| d >= 6 } ? 1 : 0 }
          .map { |r| r[:text] }
          .join(" / ")
  end
  
  

  private

  def format_time(time)
    time.strftime('%H:%M')
  end

  def day_name(index)
    %w[Sun Mon Tue Wed Thu Fri Sat][index % 7]
  end

  def format_days(days)
    days = days.sort
    # 判斷連續
    if days.size == 1
      day_name(days.first)
    elsif continuous_days?(days)
      "#{day_name(days.first)} - #{day_name(days.last)}"
    else
      days.map { |d| day_name(d) }.join(", ")
    end
  end

  def continuous_days?(days)
    days.each_cons(2).all? { |a, b| a + 1 == b }
  end
  
end
