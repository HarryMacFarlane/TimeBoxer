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

ActiveRecord::Schema[8.0].define(version: 2025_02_22_203808) do
  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "user_id"], name: "index_subjects_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "subtasks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "subtask_type", null: false
    t.text "description"
    t.boolean "completed", default: false, null: false
    t.integer "task_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "name"], name: "index_subtasks_on_task_id_and_name", unique: true
    t.index ["task_id"], name: "index_subtasks_on_task_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag_name", null: false
    t.integer "user_id", null: false
    t.string "description"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_name", "user_id"], name: "index_tags_on_tag_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "task_sessions", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "subtask_id", null: false
    t.integer "workblock_id", null: false
    t.integer "duration"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subtask_id"], name: "index_task_sessions_on_subtask_id"
    t.index ["workblock_id"], name: "index_task_sessions_on_workblock_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "deadline"
    t.integer "priority_level", null: false
    t.integer "expected_completion_time"
    t.integer "time_spent", default: 0, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_id"
    t.index ["subject_id"], name: "index_tasks_on_subject_id"
    t.index ["user_id", "name"], name: "index_tasks_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workblocks", force: :cascade do |t|
    t.integer "duration"
    t.datetime "timestamp"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_workblocks_on_user_id"
  end

  add_foreign_key "subjects", "users"
  add_foreign_key "subtasks", "tasks"
  add_foreign_key "tags", "users"
  add_foreign_key "task_sessions", "subtasks"
  add_foreign_key "task_sessions", "workblocks"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "subjects", on_delete: :nullify
  add_foreign_key "tasks", "users"
  add_foreign_key "workblocks", "users"
end
