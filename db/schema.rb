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

ActiveRecord::Schema.define(:version => 20110520213639) do

  create_table "accountants", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_impersonation_id", :default => 19
    t.integer  "customer_impersonation_id", :default => 57
  end

  create_table "attendees", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "survey_question_value"
  end

  create_table "bids", :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_payments", :force => true do |t|
    t.integer  "business_id"
    t.integer  "promotion_id"
    t.boolean  "paid",                                           :default => false
    t.decimal  "initial_amount",  :precision => 10, :scale => 2, :default => 0.0
    t.text     "payment1_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "payment1_paid",                                  :default => false
    t.boolean  "payment2_paid",                                  :default => false
    t.decimal  "payment1_amount", :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "payment2_amount", :precision => 10, :scale => 2, :default => 0.0
    t.datetime "payment1_date"
    t.datetime "payment2_date"
    t.string   "payment2_notes"
  end

  create_table "business_staffs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "business_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "businesses", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "phone"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "purchaser_rate",  :precision => 10, :scale => 2, :default => 50.0
    t.string   "email"
    t.decimal  "subscriber_rate", :precision => 10, :scale => 2, :default => 0.5
    t.string   "latitude"
    t.string   "longitude"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "deal_id"
    t.integer  "credit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity"
    t.boolean  "gift",           :default => false
    t.string   "gift_name"
    t.text     "gift_message"
    t.string   "gift_from"
    t.string   "gift_email"
    t.datetime "gift_send_date"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rotation_category", :default => 0
    t.integer  "rotation_item",     :default => 0
  end

  create_table "coupons", :force => true do |t|
    t.integer  "deal_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_id"
    t.boolean  "active",                :default => false
    t.string   "confirmation_code"
    t.boolean  "printed",               :default => false
    t.boolean  "emailed",               :default => false
    t.boolean  "used",                  :default => false
    t.integer  "number",                :default => 1
    t.boolean  "gift",                  :default => false
    t.string   "gift_name"
    t.boolean  "biz_used",              :default => false
    t.boolean  "early_bird",            :default => false
    t.boolean  "reminded",              :default => false
    t.string   "gift_email"
    t.text     "gift_message"
    t.string   "gift_from"
    t.datetime "gift_send_date"
    t.string   "gift_access_token"
    t.boolean  "mobile_used",           :default => false
    t.datetime "redemption_date"
    t.integer  "gifted_promotion_code"
    t.boolean  "refunded",              :default => false
    t.boolean  "deleted",               :default => false
  end

  create_table "credits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "referrer_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_id"
    t.integer  "promotion_code_id"
    t.integer  "cart_id"
    t.decimal  "value",             :precision => 10, :scale => 2
  end

  create_table "customers", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.boolean  "female"
    t.datetime "birthdate"
    t.boolean  "newsletter_subscriber"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipping_street1"
    t.string   "shipping_street2"
    t.string   "shipping_city"
    t.string   "shipping_state"
    t.string   "shipping_zipcode"
    t.string   "billing_street1"
    t.string   "billing_street2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zipcode"
    t.integer  "number_of_kids"
    t.integer  "employment_status"
    t.string   "employment_zipcode"
    t.integer  "annual_income"
    t.boolean  "third_party_subscriber"
    t.boolean  "quietly_created",        :default => false
    t.string   "shipping_name"
    t.string   "latitude"
    t.string   "longitude"
  end

  create_table "deals", :force => true do |t|
    t.integer  "promotion_id"
    t.string   "code"
    t.string   "name"
    t.decimal  "price",                                 :precision => 10, :scale => 2
    t.decimal  "value",                                 :precision => 10, :scale => 2
    t.text     "description"
    t.integer  "purchase_limit",                                                       :default => 9999
    t.integer  "inventory",                                                            :default => 9999
    t.string   "coupon_name"
    t.text     "coupon_description"
    t.datetime "coupon_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured"
    t.boolean  "shippable",                                                            :default => false
    t.text     "coupon_instructions"
    t.boolean  "has_coupon_code",                                                      :default => false
    t.string   "coupon_code_prefix"
    t.integer  "coupon_code_delta",                                                    :default => 0
    t.decimal  "early_bird_discount",                   :precision => 10, :scale => 2, :default => 0.0
    t.integer  "coupon_code_start",                                                    :default => 27
    t.integer  "coupon_code_number_base", :limit => 10, :precision => 10, :scale => 0, :default => 16
    t.boolean  "active",                                                               :default => true
    t.integer  "kgb_deal_id",                                                          :default => 1
  end

  create_table "delayed_emails", :force => true do |t|
    t.string   "template"
    t.integer  "user_id"
    t.datetime "delay_until"
    t.boolean  "emailed",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_subscriptions", :force => true do |t|
    t.string   "email"
    t.integer  "list"
    t.string   "referrer"
    t.boolean  "subscribed", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", :force => true do |t|
    t.integer  "raffle_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "header"
    t.string   "title"
    t.string   "image"
    t.text     "description"
    t.datetime "rotation_start_date"
    t.datetime "rotation_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_id",          :default => 0
    t.integer  "attendees_max",        :default => 0
    t.integer  "subscription_list_id", :default => 44
    t.text     "page_body"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "page_image"
    t.boolean  "hidden",               :default => false
    t.string   "read_more_text",       :default => "READ MORE"
    t.string   "survey_question"
    t.string   "image1_file_name"
    t.string   "image1_content_type"
    t.integer  "image1_file_size"
    t.datetime "image1_updated_at"
    t.string   "image2_file_name"
    t.string   "image2_content_type"
    t.integer  "image2_file_size"
    t.datetime "image2_updated_at"
    t.string   "image3_file_name"
    t.string   "image3_content_type"
    t.integer  "image3_file_size"
    t.datetime "image3_updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image1_file_name"
    t.string   "image1_content_type"
    t.integer  "image1_file_size"
    t.datetime "image1_updated_at"
    t.datetime "end_date"
  end

  create_table "kgb_coupons", :force => true do |t|
    t.datetime "date_exported"
    t.string   "transactions_transaction_id"
    t.integer  "transactions_deal_id"
    t.integer  "transactions_user_id"
    t.integer  "transactions_quantity"
    t.decimal  "transactions_total_amount",   :precision => 10, :scale => 2
    t.datetime "transactions_timestamp"
    t.string   "users_first_name"
    t.string   "users_last_name"
    t.string   "users_email"
    t.integer  "deals_merchant_id"
    t.string   "deals_title"
    t.decimal  "deals_price",                 :precision => 10, :scale => 2
    t.datetime "deals_coupon_expires"
    t.string   "merchants_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "biz_used",                                                   :default => false
    t.boolean  "used",                                                       :default => false
    t.boolean  "mobile_used",                                                :default => false
    t.datetime "redemption_date"
  end

  create_table "locations", :force => true do |t|
    t.integer  "business_id"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "origins", :force => true do |t|
    t.string   "name"
    t.integer  "origin_type"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_id"
    t.string   "sub_id"
    t.string   "placement_id"
    t.string   "source"
    t.string   "medium"
    t.string   "campaign"
  end

  create_table "payment_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "payment_cim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "billing_cc_last_four"
    t.string   "billing_cc_year"
    t.string   "billing_address1"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
  end

  create_table "promotion_codes", :force => true do |t|
    t.string   "code"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.decimal  "value",      :precision => 10, :scale => 2
    t.integer  "use_limit"
    t.boolean  "restricted"
    t.boolean  "listed",                                    :default => false
    t.boolean  "active",                                    :default => true
  end

  create_table "promotions", :force => true do |t|
    t.string   "name"
    t.integer  "quota",                                                             :default => 0
    t.boolean  "featured"
    t.boolean  "active"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_id"
    t.text     "restrictions"
    t.text     "ad_description"
    t.decimal  "profit_percentage",                  :precision => 10, :scale => 2, :default => 30.0
    t.datetime "start_date"
    t.string   "header"
    t.string   "image1_file_name"
    t.string   "legacy_image1"
    t.string   "legacy_ad_image"
    t.string   "legacy_image2"
    t.string   "thumbnail_image"
    t.string   "ad_image2"
    t.text     "body1"
    t.text     "body2"
    t.string   "ad_description2"
    t.boolean  "washingtonian_featured",                                            :default => false
    t.string   "ad_description3"
    t.string   "ad_image3"
    t.string   "external_url"
    t.boolean  "hidden",                                                            :default => false
    t.integer  "position",                                                          :default => 0
    t.boolean  "auto_activate_coupons",                                             :default => false
    t.string   "image1_content_type"
    t.integer  "image1_file_size"
    t.datetime "image1_updated_at"
    t.string   "image2_file_name"
    t.string   "image2_content_type"
    t.integer  "image2_file_size"
    t.datetime "image2_updated_at"
    t.string   "ad_image1_file_name"
    t.string   "ad_image1_content_type"
    t.integer  "ad_image1_file_size"
    t.datetime "ad_image1_updated_at"
    t.integer  "partner_id",                                                        :default => 0
    t.text     "summary"
    t.integer  "inventory",                                                         :default => 9999
    t.string   "map_replacement_image_file_name"
    t.string   "map_replacement_image_content_type"
    t.integer  "map_replacement_image_file_size"
    t.datetime "map_replacement_image_updated_at"
    t.boolean  "credit_restriction",                                                :default => false
    t.string   "ad_description4"
    t.string   "ad_description5"
    t.string   "ad_description6"
    t.string   "ad_description7"
    t.boolean  "halfpricedc_featured",                                              :default => false
    t.boolean  "physical_address",                                                  :default => true
    t.string   "slug"
    t.boolean  "grab_bag",                                                          :default => false
  end

  create_table "purchases", :force => true do |t|
    t.string   "invoice_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.decimal  "total",                 :precision => 10, :scale => 2
    t.string   "ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "card_type"
    t.string   "card_number_masked"
    t.string   "billing_street1"
    t.string   "billing_street2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zipcode"
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.integer  "card_expires_on_month"
    t.integer  "card_expires_on_year"
    t.decimal  "deals_total",           :precision => 10, :scale => 2, :default => 0.0
    t.integer  "partner_id",                                           :default => 0
    t.string   "shipping_address1"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.string   "shipping_state"
    t.string   "shipping_zipcode"
    t.string   "shipping_name"
    t.boolean  "deleted",                                              :default => false
  end

  create_table "raffles", :force => true do |t|
    t.string   "header"
    t.text     "body"
    t.datetime "rotation_start_date"
    t.datetime "rotation_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image1_file_name"
    t.string   "image1_content_type"
    t.integer  "image1_file_size"
    t.datetime "image1_updated_at"
    t.integer  "business_id"
    t.integer  "subscription_list_id", :default => 44
    t.boolean  "hidden",               :default => false
  end

  create_table "refunds", :force => true do |t|
    t.integer  "purchase_id"
    t.integer  "credit_id"
    t.decimal  "cc_amount",     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "credit_amount", :precision => 10, :scale => 2, :default => 0.0
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processed",                                    :default => false
  end

  create_table "reminders", :force => true do |t|
    t.integer  "promotion_id"
    t.string   "email"
    t.boolean  "emailed",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shoutouts", :force => true do |t|
    t.string   "header"
    t.string   "title"
    t.string   "image"
    t.text     "description"
    t.datetime "rotation_start_date"
    t.datetime "rotation_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image1_file_name"
    t.string   "image1_content_type"
    t.integer  "image1_file_size"
    t.datetime "image1_updated_at"
  end

  create_table "staffs", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscribers", :force => true do |t|
    t.string   "email"
    t.integer  "origin_id",  :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "partner_id", :default => 0
    t.string   "fist_name"
    t.string   "last_name"
    t.string   "zipcode"
  end

  create_table "user_reviews", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "reviewed",         :default => false
    t.boolean  "credit_given"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "referred_user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                 :null => false
    t.string   "crypted_password",                                      :null => false
    t.string   "password_salt",                                         :null => false
    t.string   "persistence_token",                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "perishable_token",                   :default => "",    :null => false
    t.integer  "origin_id",                          :default => 1
    t.string   "customer_cim_id"
    t.integer  "partner_id",                         :default => 0
    t.boolean  "gets_coupon_expiring_email",         :default => true
    t.boolean  "gets_referral_notification_email",   :default => true
    t.boolean  "gets_coupon_ready_email",            :default => true
    t.boolean  "gets_happy_hour_announcement_email", :default => false
    t.boolean  "gets_daily_deal_email",              :default => false
    t.boolean  "quietly_created",                    :default => false
    t.boolean  "gets_va_daily_deal_email",           :default => false
    t.boolean  "gets_md_daily_deal_email",           :default => false
  end

  add_index "users", ["email"], :name => "email", :unique => true

  create_table "voids", :force => true do |t|
    t.integer  "purchase_id"
    t.boolean  "processed",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
