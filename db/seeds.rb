require 'json'
require_relative '../lib/time_parser'

# Clean up data
OrderItem.destroy_all
Order.destroy_all
PharmacyOpeningHour.destroy_all
Mask.destroy_all
Pharmacy.destroy_all
User.destroy_all
MaskType.destroy_all

ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE pharmacies_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE masks_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE orders_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE order_items_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE mask_types_id_seq RESTART WITH 1")

# Load pharmacies data
pharmacies = JSON.parse(File.read(Rails.root.join('db', 'pharmacies.json')))

mask_type_names = pharmacies.flat_map { |p| (p['masks'] || []).map { |m| m['name'] } }

mask_type_names.uniq.each do |name|
  MaskType.find_or_create_by!(name: name)
end

pharmacies.each do |p|
  pharmacy = Pharmacy.create!(
    name: p['name'],
    phone: p['phone'],
    address: p['address'],
    cash_balance: p['cashBalance']
  )

  # Opening Hours
  if p['openingHours']
    TimeParser.parse_time_string(p['openingHours']).each do |hour|
      day_of_week = hour[:day_of_week]

      open_time = TimeParser.build_time(hour[:open_time])
      close_time = TimeParser.build_time(hour[:close_time])
      over_night_time = TimeParser.build_time("00:00")
     
      if close_time <= open_time
        pharmacy.pharmacy_opening_hours.create!(
          day_of_week: day_of_week,
          open_time: open_time,
          close_time: over_night_time
        )
    
        pharmacy.pharmacy_opening_hours.create!(
          day_of_week: (day_of_week + 1) % 7,
          open_time: over_night_time,
          close_time: close_time
        )
      else
        pharmacy.pharmacy_opening_hours.create!(
          day_of_week: day_of_week,
          open_time: open_time,
          close_time: close_time,
        )
      end
    end
  end
  

  # 建立 masks (with mask_type_id)
  p['masks'].each do |m|
    mask_type = MaskType.find_by!(name: m['name'])

    pharmacy.masks.create!(
      mask_type: mask_type,
      price: m['price'],
      stock: rand(10..100)
    )
    end
  end



# Load users data
users = JSON.parse(File.read(Rails.root.join('db', 'users.json')))

users.each do |u|
  user = User.create!(
    name: u['name'],
    phone_number: "09#{rand(10**8).to_s.rjust(8, '0')}",  # 隨機產生09開頭的手機號碼
    cash_balance: u['cashBalance']
  )

  # Handle purchase histories
  next unless u['purchaseHistories']

  u['purchaseHistories'].each do |history|
    pharmacy = Pharmacy.find_by(name: history['pharmacyName'])

    mask_type = MaskType.find_by(name: history['maskName'])
    mask = Mask.find_by(mask_type: mask_type, pharmacy_id: pharmacy.id)

    # Skip if not found
    next unless pharmacy && mask

    order = Order.create!(
      user: user,
      pharmacy: pharmacy,
      total_price: history['transactionAmount'],
      created_at: history['transactionDate'],
      updated_at: history['transactionDate']
    )

    OrderItem.create!(
      order: order,
      mask: mask,
      quantity: 1, # json 裡沒數量，先當1
      price: history['transactionAmount']
    )
  end
end


