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

ActiveRecord::Schema.define(version: 20140207094232) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bad_words", force: true do |t|
    t.string   "word",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bad_words", ["word"], name: "index_bad_words_on_word", unique: true, using: :btree

  create_table "failed_videos", force: true do |t|
    t.string   "md5",        limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", force: true do |t|
    t.string   "keyword",    null: false
    t.string   "categories", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "magnet_sources", force: true do |t|
    t.string   "magnet_keyword",               null: false
    t.integer  "category",                     null: false
    t.integer  "sort_by",         default: 7,  null: false
    t.integer  "number_of_pages", default: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "keyword_id"
  end

  add_index "magnet_sources", ["keyword_id"], name: "index_magnet_sources_on_keyword_id", using: :btree
  add_index "magnet_sources", ["magnet_keyword", "category"], name: "index_magnet_sources_on_magnet_keyword_and_category", unique: true, using: :btree

  create_table "magnets", force: true do |t|
    t.text     "link",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                        null: false
    t.integer  "seeders",                      null: false
    t.integer  "leechers",                     null: false
    t.string   "category",                     null: false
    t.integer  "torrent_id",                   null: false
    t.string   "url",                          null: false
    t.integer  "magnet_source_id",             null: false
    t.integer  "flags",            default: 0, null: false
    t.string   "workflow_state"
  end

  add_index "magnets", ["magnet_source_id"], name: "index_magnets_on_magnet_source_id", using: :btree
  add_index "magnets", ["torrent_id"], name: "index_magnets_on_torrent_id", unique: true, using: :btree

  create_table "videos", force: true do |t|
    t.string   "name",                                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size",       limit: 8
    t.datetime "video_updated_at"
    t.string   "duration",                                     null: false
    t.integer  "flags",                            default: 0, null: false
    t.string   "original_md5_checksum", limit: 32
    t.datetime "deleted_at"
    t.string   "videoable_type"
    t.integer  "videoable_id"
  end

  add_index "videos", ["videoable_id", "videoable_type"], name: "index_videos_on_videoable_id_and_videoable_type", using: :btree

end
