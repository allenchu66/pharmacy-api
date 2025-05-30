# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_03_054850) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mask_purchases", force: :cascade do |t|
    t.bigint "pharmacy_id", null: false
    t.bigint "mask_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mask_id"], name: "index_mask_purchases_on_mask_id"
    t.index ["pharmacy_id"], name: "index_mask_purchases_on_pharmacy_id"
  end

  create_table "mask_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "color"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masks", force: :cascade do |t|
    t.decimal "price"
    t.integer "stock"
    t.bigint "pharmacy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mask_type_id"
    t.decimal "unit_price", precision: 10, scale: 2
    t.index ["mask_type_id"], name: "index_masks_on_mask_type_id"
    t.index ["pharmacy_id"], name: "index_masks_on_pharmacy_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "mask_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mask_id"], name: "index_order_items_on_mask_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pharmacy_id", null: false
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pharmacy_id"], name: "index_orders_on_pharmacy_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pharmacies", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "address"
    t.decimal "cash_balance", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pharmacy_opening_hours", force: :cascade do |t|
    t.bigint "pharmacy_id", null: false
    t.integer "day_of_week"
    t.time "open_time"
    t.time "close_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pharmacy_id"], name: "index_pharmacy_opening_hours_on_pharmacy_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.decimal "cash_balance", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "mask_purchases", "masks"
  add_foreign_key "mask_purchases", "pharmacies"
  add_foreign_key "masks", "pharmacies"
  add_foreign_key "order_items", "masks"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "pharmacies"
  add_foreign_key "orders", "users"
  add_foreign_key "pharmacy_opening_hours", "pharmacies"
end
