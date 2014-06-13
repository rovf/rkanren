# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140613092223) do

  create_table "cards", force: true do |t|
    t.integer  "dict_id"
    t.integer  "n_repres",   limit: 1
    t.text     "usernote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cards", ["dict_id"], name: "index_cards_on_dict_id"

  create_table "dicts", force: true do |t|
    t.string   "dictname",        limit: 16
    t.integer  "user_id"
    t.datetime "accessed"
    t.string   "language",        limit: 32
    t.integer  "max_level_kanji", limit: 3
    t.integer  "max_level_kana",  limit: 3
    t.integer  "max_level_gaigo", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dicts", ["dictname"], name: "index_dicts_on_dictname"
  add_index "dicts", ["user_id"], name: "index_dicts_on_user_id"

  create_table "idioms", force: true do |t|
    t.string   "repres",     limit: 128
    t.integer  "card_id"
    t.integer  "kind",       limit: 1
    t.text     "note"
    t.integer  "level",      limit: 3
    t.integer  "atari"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "idioms", ["card_id"], name: "index_idioms_on_card_id"
  add_index "idioms", ["repres"], name: "index_idioms_on_repres"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], name: "index_users_on_name"

end
