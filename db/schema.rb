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

ActiveRecord::Schema[8.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_branches_on_organization_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "vendor_id"
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.text "terms"
    t.string "signed_by"
    t.datetime "signed_at"
    t.string "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_contracts_on_organization_id"
    t.index ["vendor_id"], name: "index_contracts_on_vendor_id"
  end

  create_table "delivery_orders", force: :cascade do |t|
    t.string "order_number"
    t.integer "branch_id"
    t.integer "vendor_id"
    t.integer "created_by_id"
    t.datetime "delivery_date"
    t.string "status"
    t.text "delivery_instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_delivery_orders_on_branch_id"
    t.index ["created_by_id"], name: "index_delivery_orders_on_created_by_id"
    t.index ["order_number"], name: "index_delivery_orders_on_order_number", unique: true
    t.index ["vendor_id"], name: "index_delivery_orders_on_vendor_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "documentable_type"
    t.integer "documentable_id"
    t.string "file"
    t.string "document_type"
    t.string "original_filename"
    t.string "content_type"
    t.integer "uploaded_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
    t.index ["uploaded_by_id"], name: "index_documents_on_uploaded_by_id"
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "name"
    t.boolean "enabled", default: false
    t.string "flaggable_type"
    t.integer "flaggable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flaggable_type", "flaggable_id"], name: "index_feature_flags_on_flaggable"
    t.index ["name"], name: "index_feature_flags_on_name"
  end

  create_table "login_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_login_histories_on_user_id"
  end

  create_table "order_chats", force: :cascade do |t|
    t.integer "delivery_order_id"
    t.integer "user_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_order_chats_on_delivery_order_id"
    t.index ["user_id"], name: "index_order_chats_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "delivery_order_id"
    t.integer "product_id"
    t.decimal "quantity"
    t.decimal "price_per_unit"
    t.string "unit"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_order_items_on_delivery_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "tax_id"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "product_code"
    t.decimal "price_per_unit"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "storage_products", force: :cascade do |t|
    t.integer "storage_id"
    t.integer "product_id"
    t.decimal "current_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_storage_products_on_product_id"
    t.index ["storage_id"], name: "index_storage_products_on_storage_id"
  end

  create_table "storages", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.decimal "capacity"
    t.string "capacity_unit"
    t.integer "branch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_storages_on_branch_id"
  end

  create_table "sync_logs", force: :cascade do |t|
    t.integer "third_party_integration_id"
    t.string "syncable_type"
    t.integer "syncable_id"
    t.string "status"
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["syncable_type", "syncable_id"], name: "index_sync_logs_on_syncable"
    t.index ["third_party_integration_id"], name: "index_sync_logs_on_third_party_integration_id"
  end

  create_table "third_party_integrations", force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.string "api_secret"
    t.string "base_url"
    t.integer "organization_id"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_third_party_integrations_on_organization_id"
  end

  create_table "trucks", force: :cascade do |t|
    t.string "license_plate"
    t.string "make"
    t.string "model"
    t.integer "year"
    t.integer "branch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_trucks_on_branch_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "phone"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.boolean "active", default: true
    t.datetime "last_seen_at"
    t.integer "failed_login_attempts", default: 0
    t.datetime "locked_at"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.integer "organization_id"
    t.boolean "preferred", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_vendors_on_organization_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end
end
