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

ActiveRecord::Schema[7.1].define(version: 2025_04_10_130922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "masks", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.integer "stock"
    t.bigint "pharmacy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pharmacy_id"], name: "index_masks_on_pharmacy_id"
  end

  create_table "pharmacies", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "address"
    t.string "open_time"
    t.string "close_time"
    t.integer "cash_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchase_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pharmacy_id", null: false
    t.bigint "mask_id", null: false
    t.integer "quantity"
    t.integer "total_price"
    t.datetime "purchased_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mask_id"], name: "index_purchase_records_on_mask_id"
    t.index ["pharmacy_id"], name: "index_purchase_records_on_pharmacy_id"
    t.index ["user_id"], name: "index_purchase_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "cash_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "masks", "pharmacies"
  add_foreign_key "purchase_records", "masks"
  add_foreign_key "purchase_records", "pharmacies"
  add_foreign_key "purchase_records", "users"
end
