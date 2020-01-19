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

ActiveRecord::Schema.define(:version => 8) do

  create_table "announcements", :force => true do |t|
    t.integer  "user_id", :null => false
    t.string   "title",   :null => false
    t.text     "body",    :null => false
    t.datetime "posted",  :null => false
  end

  create_table "chat_messages", :force => true do |t|
    t.string   "user", :default => "", :null => false
    t.text     "text",                 :null => false
    t.datetime "date",                 :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "recipient", :default => "", :null => false
    t.string   "sender",    :default => "", :null => false
    t.string   "replyTo",   :default => "", :null => false
    t.text     "body"
    t.datetime "date",                      :null => false
  end

  create_table "images", :force => true do |t|
    t.integer   "portfolio_id", :default => 0,     :null => false
    t.string    "title",        :default => "",    :null => false
    t.string    "fileName",     :default => "",    :null => false
    t.text      "description",                     :null => false
    t.integer   "position",     :default => 0,     :null => false
    t.integer   "duration",     :default => 10,    :null => false
    t.boolean   "rollover",     :default => false, :null => false
    t.timestamp "uploaded",                        :null => false
  end

  create_table "infos", :force => true do |t|
    t.integer "user_id",                          :default => 0,        :null => false
    t.string  "name",                             :default => "",       :null => false
    t.string  "email",                            :default => "",       :null => false
    t.boolean "enabled",                          :default => false,    :null => false
    t.string  "title",                            :default => "",       :null => false
    t.string  "description",       :limit => 200
    t.string  "keywords",          :limit => 200
    t.string  "verifyv1",          :limit => 200
    t.text    "biography"
    t.boolean "biodisplay",                       :default => false,    :null => false
    t.boolean "resumedisplay",                    :default => false,    :null => false
    t.string  "bgcolor",           :limit => 6,   :default => "000000", :null => false
    t.string  "textcolor",         :limit => 6,   :default => "AAAAAA", :null => false
    t.string  "thumbbgcolor",      :limit => 6,   :default => "222222", :null => false
    t.string  "arrowcolor",        :limit => 6,   :default => "888888", :null => false
    t.integer "thumbbgalpha",                     :default => 50,       :null => false
    t.integer "arrowalpha",                       :default => 80,       :null => false
    t.boolean "bannerdisplay",                    :default => false,    :null => false
    t.boolean "splashdisplay",                    :default => false,    :null => false
    t.boolean "arrowdisplay",                     :default => false,    :null => false
    t.string  "highlightcolor",    :limit => 6,   :default => "666666", :null => false
    t.string  "color5",            :limit => 6,   :default => "666666", :null => false
    t.boolean "biopicdisplay",                    :default => false,    :null => false
    t.integer "template",                         :default => 0,        :null => false
    t.integer "transition",                       :default => 0,        :null => false
    t.integer "transitionspeed",                  :default => 50,       :null => false
    t.integer "arrowsize",                        :default => 30,       :null => false
    t.boolean "psslinkdisplay",                   :default => false,    :null => false
    t.boolean "audioplay",                        :default => false,    :null => false
    t.boolean "audioloop",                        :default => false,    :null => false
    t.text    "analytics"
    t.string  "link1",             :limit => 30
    t.string  "link2",             :limit => 30
    t.string  "link3",             :limit => 30
    t.string  "link1_address"
    t.string  "link2_address"
    t.string  "link3_address"
    t.boolean "audio",                            :default => false
    t.boolean "banner",                           :default => false
    t.boolean "biopic",                           :default => false
    t.boolean "favicon",                          :default => false
    t.boolean "resume",                           :default => false
    t.boolean "splash",                           :default => false
    t.string  "link_portfolios",   :limit => 30
    t.string  "link_multimedia",   :limit => 30
    t.string  "link_biography",    :limit => 30
    t.string  "link_contact",      :limit => 30
    t.string  "link_resume",       :limit => 30
    t.string  "toptext"
    t.string  "innerbgcolor",                     :default => "000000", :null => false
    t.integer "innerbgalpha",                     :default => 0,        :null => false
    t.integer "bgtype",                           :default => 0,        :null => false
    t.integer "bgpos",                            :default => 0,        :null => false
    t.integer "bgrepeat",                         :default => 0,        :null => false
    t.integer "bggradient",                       :default => 0,        :null => false
    t.boolean "bgimage"
    t.string  "link_clientaccess"
    t.text    "contact_info"
  end

  create_table "portfolios", :force => true do |t|
    t.integer "user_id",            :default => 0,     :null => false
    t.string  "title",              :default => "",    :null => false
    t.integer "position",           :default => 0,     :null => false
    t.boolean "hidden",             :default => true
    t.text    "description"
    t.boolean "descriptionsHidden", :default => true
    t.boolean "slideshow",          :default => false, :null => false
    t.integer "images_count",       :default => 0
    t.boolean "audio",              :default => false
    t.boolean "private",            :default => false
    t.string  "password"
  end

  create_table "servers", :force => true do |t|
    t.boolean "updating", :default => false, :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "users", :force => true do |t|
    t.string    "user",                           :default => "",    :null => false
    t.string    "pass",                           :default => "",    :null => false
    t.timestamp "signup",                                            :null => false
    t.boolean   "wide",                           :default => false, :null => false
    t.string    "website",                        :default => "",    :null => false
    t.string    "name",                           :default => "",    :null => false
    t.string    "contactemail",                   :default => "",    :null => false
    t.string    "directory",        :limit => 20, :default => "",    :null => false
    t.string    "status",           :limit => 20, :default => "New", :null => false
    t.string    "grade",            :limit => 20, :default => "Pro", :null => false
    t.boolean   "admin",                          :default => false, :null => false
    t.integer   "subscription",                   :default => 0,     :null => false
    t.integer   "portfolios_count",               :default => 0
    t.timestamp "last_action",                                       :null => false
  end

end
