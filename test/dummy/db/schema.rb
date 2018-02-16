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

ActiveRecord::Schema.define(version: 20180207213738) do

  create_table "product_languages", force: :cascade do |t|
    t.integer "localizable_object_id"
    t.string "locale", default: "en", null: false
    t.string "name"
    t.index ["localizable_object_id"], name: "index_product_languages_on_localizable_object_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thing_languages", force: :cascade do |t|
    t.integer "localizable_object_id"
    t.string "name"
    t.string "locale", default: "en", null: false
    t.index ["localizable_object_id"], name: "index_thing_languages_on_localizable_object_id"
  end

  create_table "things", force: :cascade do |t|
    t.integer "product_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_things_on_product_id"
  end

end
