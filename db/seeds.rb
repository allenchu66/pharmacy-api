require 'json'
require_relative '../lib/time_parser'

# Clean up data
OrderItem.destroy_all
Order.destroy_all
PharmacyOpeningHour.destroy_all
Mask.destroy_all
Pharmacy.destroy_all
User.destroy_all

ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE pharmacies_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE masks_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE orders_id_seq RESTART WITH 1")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE order_items_id_seq RESTART WITH 1")
# Load pharmacies data
pharmacies = JSON.parse(File.read(Rails.root.join('db', 'pharmacies.json')))

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
      pharmacy.pharmacy_opening_hours.create!(hour)
    end
  end

  # Masks with random stock
  if p['masks']
    p['masks'].each do |m|
      pharmacy.masks.create!(
        name: m['name'],
        price: m['price'],
        stock: rand(10..100) # Random 
      )
    end
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
    mask = Mask.find_by(name: history['maskName'], pharmacy_id: pharmacy.id)

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
