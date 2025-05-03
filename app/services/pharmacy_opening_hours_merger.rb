class PharmacyOpeningHoursMerger
  def self.call(opening_hours)
    grouped = opening_hours.group_by(&:pharmacy_id).transform_values do |hours|
      merged   = []
      skip_idx = Set.new

      sorted = hours.sort_by { |h| [h.day_of_week, h.open_time] }

      sorted.each_with_index do |hour, i|
        next if skip_idx.include?(i)

        o = hour.open_time.strftime('%H:%M')
        c = hour.close_time.strftime('%H:%M')

        if c == "00:00"
          nd = (hour.day_of_week + 1) % 7
          pair = sorted.each_with_index.find do |nh, j|
            nh.day_of_week == nd &&
            nh.open_time.strftime('%H:%M') == "00:00" &&
            !skip_idx.include?(j)
          end
          if pair
            _match, j = pair
            merged << {
              day_of_week: hour.day_of_week,
              open_time:   o,
              close_time:  _match.close_time.strftime('%H:%M')
            }
            skip_idx << i << j
            next
          end
        end

        merged << {
          day_of_week: hour.day_of_week,
          open_time:   o,
          close_time:  c
        }
      end

      merged.reject! { |e| e[:open_time] == "00:00" }

      merged
    end

    grouped
  end
end
