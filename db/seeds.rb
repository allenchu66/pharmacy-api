require 'json'
require_relative '../lib/time_parser'

# Clean up data
PharmacyOpeningHour.destroy_all
Mask.destroy_all
Pharmacy.destroy_all
User.destroy_all

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
  User.create!(
    name: u['name'],
    cash_balance: u['cashBalance']
  )
end
