require 'json'
require_relative '../lib/time_parser'

# Clean up data
PharmacyOpeningHour.destroy_all
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

  next unless p['openingHours']

  TimeParser.parse_time_string(p['openingHours']).each do |hour|
    pharmacy.pharmacy_opening_hours.create!(hour)
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
