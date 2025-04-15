namespace :import_data do
    desc "Import pharmacies data"
    task :pharmacies, [:path] => :environment do |t, args|
      require 'json'
      require_relative '../../lib/time_parser'
  
      raise "File path is required" unless args[:path]
  
      pharmacies = JSON.parse(File.read(args[:path]))
  
      OrderItem.destroy_all
      Order.destroy_all
      MaskPurchase.destroy_all
      Mask.destroy_all
      PharmacyOpeningHour.destroy_all
      Pharmacy.destroy_all
      MaskType.destroy_all
  
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE pharmacies_id_seq RESTART WITH 1")
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE masks_id_seq RESTART WITH 1")
  
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
  
        if p['openingHours']
          TimeParser.parse_time_string(p['openingHours']).each do |hour|
            pharmacy.pharmacy_opening_hours.create!(hour)
          end
        end
  
        p['masks'].each do |m|
          mask_type = MaskType.find_by!(name: m['name'])
  
          pharmacy.masks.create!(
            mask_type: mask_type,
            price: m['price'],
            stock: rand(10..100)
          )
        end
      end
  
      puts "Pharmacies data imported successfully."
    end
  
    desc "Import users data"
    task :users, [:path] => :environment do |t, args|
      require 'json'
  
      raise "File path is required" unless args[:path]
  
      users = JSON.parse(File.read(args[:path]))
  
      OrderItem.destroy_all
      Order.destroy_all
      User.destroy_all
  
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq RESTART WITH 1")
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE orders_id_seq RESTART WITH 1")
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE order_items_id_seq RESTART WITH 1")
  
      users.each do |u|
        user = User.create!(
          name: u['name'],
          phone_number: "09#{rand(10**8).to_s.rjust(8, '0')}",
          cash_balance: u['cashBalance']
        )
  
        next unless u['purchaseHistories']
  
        u['purchaseHistories'].each do |history|
          pharmacy = Pharmacy.find_by(name: history['pharmacyName'])
          mask_type = MaskType.find_by(name: history['maskName'])
          mask = Mask.find_by(mask_type: mask_type, pharmacy_id: pharmacy.id)
  
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
            quantity: 1,
            price: history['transactionAmount']
          )
        end
      end
  
      puts "Users data imported successfully."
    end
  end
  