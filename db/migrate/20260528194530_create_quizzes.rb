class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :region, null: false
      t.integer :duration_seconds, null: false, default: 300

      t.index :slug, unique: true

      t.timestamps
    end
  end
end
