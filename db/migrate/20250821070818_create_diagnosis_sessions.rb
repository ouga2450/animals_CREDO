class CreateDiagnosisSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :diagnosis_sessions do |t|
      t.string :session_token, null: false, comment: 'セッション識別子'
      t.json :answers, comment: '回答データ(JSON形式)'
      t.string :result_animal_type, comment: '診断結果の動物タイプ（crab, monkey等）'
      t.datetime :completed_at, comment: '診断完了日時'
      t.datetime :expires_at, null: false, comment: 'セッション期限'

      t.timestamps
    end

    add_index :diagnosis_sessions, :session_token, unique: true
    # セッション削除用
    add_index :diagnosis_sessions, :expires_at
    # 統計用
    add_index :diagnosis_sessions, :result_animal_type
  end
end
