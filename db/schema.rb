# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100109154847) do

  create_table "addresses", :force => true do |t|
    t.string   "zip_code"
    t.string   "prefecture"
    t.string   "district"
    t.string   "town",            :limit => 2048
    t.string   "kana_prefecture"
    t.string   "kana_district"
    t.string   "kana_town",       :limit => 2048
    t.boolean  "is_merge"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["district"], :name => "index_addresses_on_district"
  add_index "addresses", ["kana_district"], :name => "index_addresses_on_kana_district"
  add_index "addresses", ["kana_prefecture"], :name => "index_addresses_on_kana_prefecture"
  add_index "addresses", ["kana_town"], :name => "index_addresses_on_kana_town"
  add_index "addresses", ["prefecture"], :name => "index_addresses_on_prefecture"
  add_index "addresses", ["town"], :name => "index_addresses_on_town"
  add_index "addresses", ["zip_code"], :name => "index_addresses_on_zip_code"

  create_table "answers", :force => true do |t|
    t.text     "content"
    t.text     "supplement_comment"
    t.text     "thanks_comment"
    t.string   "url"
    t.integer  "kind"
    t.integer  "confidence"
    t.integer  "character"
    t.boolean  "receive_mail"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id", "created_at"], :name => "index_answers_on_question_id_and_created_at"
  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "is_most_underlayer", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "company_informations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "photos", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "company_information_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "state"
    t.boolean  "is_closed",    :default => false
    t.boolean  "receive_mail", :default => true
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["category_id", "created_at"], :name => "index_questions_on_category_id_and_created_at"
  add_index "questions", ["category_id"], :name => "index_questions_on_category_id"
  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "identity_url"
    t.string   "mobile_ident"
    t.integer  "carrier"
  end

  add_index "users", ["identity_url"], :name => "index_users_on_identity_url"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
