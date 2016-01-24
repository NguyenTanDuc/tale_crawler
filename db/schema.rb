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

ActiveRecord::Schema.define(version: 20160123164306) do

  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chapters", force: true do |t|
    t.integer  "tale_id"
    t.string   "title"
    t.integer  "chapter"
    t.text     "content_text", limit: 16777215
    t.text     "content_html", limit: 16777215
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chapters", ["tale_id"], name: "index_chapters_on_tale_id", using: :btree

  create_table "tale_links", force: true do |t|
    t.string   "tale_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tales", force: true do |t|
    t.string   "name"
    t.integer  "author_id"
    t.integer  "category_id"
    t.string   "source"
    t.string   "link"
    t.boolean  "status"
    t.integer  "chapter_number"
    t.integer  "last_chapter"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tales", ["author_id"], name: "index_tales_on_author_id", using: :btree
  add_index "tales", ["category_id"], name: "index_tales_on_category_id", using: :btree

end
