# lib/tasks/split_overnight_opening_hours.rake
namespace :pharmacy do
    desc "Split overnight opening hours into two records"
    task split_overnight_hours: :environment do
      PharmacyOpeningHour.find_each do |hour|
        next if hour.open_time.blank? || hour.close_time.blank?
  
        open_time = Time.parse(hour.open_time.strftime("%H:%M"))
        close_time = Time.parse(hour.close_time.strftime("%H:%M"))
  
        if close_time <= open_time
          puts "Splitting: #{hour.inspect}"
  
          PharmacyOpeningHour.create!(
            pharmacy_id: hour.pharmacy_id,
            day_of_week: hour.day_of_week,
            open_time: hour.open_time,
            close_time: Time.parse("24:00")
          )
  
          PharmacyOpeningHour.create!(
            pharmacy_id: hour.pharmacy_id,
            day_of_week: (hour.day_of_week + 1) % 7,
            open_time: Time.parse("00:00"),
            close_time: hour.close_time
          )
  
          hour.destroy!
        end
      end
  
      puts "Done splitting overnight hours"
    end
  end
  