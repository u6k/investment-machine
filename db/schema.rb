# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180513102746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dow_jones_industrial_averages", force: :cascade do |t|
    t.date "date"
    t.decimal "opening_price", precision: 10, scale: 2
    t.decimal "high_price", precision: 10, scale: 2
    t.decimal "low_price", precision: 10, scale: 2
    t.decimal "close_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nikkei_averages", force: :cascade do |t|
    t.date "date"
    t.decimal "opening_price", precision: 10, scale: 2
    t.decimal "high_price", precision: 10, scale: 2
    t.decimal "low_price", precision: 10, scale: 2
    t.decimal "close_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_prices", force: :cascade do |t|
    t.date "date"
    t.integer "opening_price"
    t.integer "high_price"
    t.integer "low_price"
    t.integer "close_price"
    t.integer "turnover"
    t.integer "adjustment_value"
    t.bigint "stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_prices_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker_symbol"
    t.string "company_name"
    t.string "market"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topixes", force: :cascade do |t|
    t.date "date"
    t.decimal "opening_price", precision: 10, scale: 2
    t.decimal "high_price", precision: 10, scale: 2
    t.decimal "low_price", precision: 10, scale: 2
    t.decimal "close_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wertpapier_reports", force: :cascade do |t|
    t.string "ticker_symbol"
    t.string "report_id"
    t.date "date_from"
    t.date "date_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "stock_prices", "stocks"
end
