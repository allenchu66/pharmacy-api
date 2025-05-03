class TimeParser
  DAY_MAP = {
  'Sun' => 0,
  'Mon' => 1,
  'Tue' => 2,
  'Wed' => 3,
  'Thu' => 4,
  'Thur' => 4,
  'Fri' => 5,
  'Sat' => 6
}

  def self.parse_time_string(raw_string)
    result = []
  
    raw_string.split('/').each do |block|
      match = block.strip.match(/(.+?)\s+(\d{2}:\d{2}\s*-\s*\d{2}:\d{2})/)
      next unless match
  
      day_part = match[1].strip
      time_part = match[2].strip
  
      days = expand_days(day_part)
      open_time, close_time = time_part.split('-').map(&:strip)
  
      days.each do |day|
        result << {
          day_of_week: day,
          open_time: open_time,
          close_time: close_time
        }
      end
    end
  
    result
  end
  

  def self.expand_days(day_string)
    day_string.split(',').flat_map do |part|
      part = part.strip
      if part.include?('-')
        from, to = part.split('-').map(&:strip)
        from_idx = DAY_MAP[from]
        to_idx = DAY_MAP[to]
        if from_idx <= to_idx
          (from_idx..to_idx).to_a
        else
          (from_idx..6).to_a + (0..to_idx).to_a
        end
      else
        [DAY_MAP[part]]
      end
    end
  end

  def self.build_time(str)
    h, m = str.split(":").map(&:to_i)
    Time.zone.local(2000, 1, 1, h, m)
  end
end

