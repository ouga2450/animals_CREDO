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

ActiveRecord::Schema[7.2].define(version: 2025_08_21_070818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "diagnosis_sessions", force: :cascade do |t|
    t.string "session_token", null: false, comment: "セッション識別子"
    t.json "answers", comment: "回答データ(JSON形式)"
    t.string "result_animal_type", comment: "診断結果の動物タイプ（crab, monkey等）"
    t.datetime "completed_at", comment: "診断完了日時"
    t.datetime "expires_at", null: false, comment: "セッション期限"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_diagnosis_sessions_on_expires_at"
    t.index ["result_animal_type"], name: "index_diagnosis_sessions_on_result_animal_type"
    t.index ["session_token"], name: "index_diagnosis_sessions_on_session_token", unique: true
  end
end
