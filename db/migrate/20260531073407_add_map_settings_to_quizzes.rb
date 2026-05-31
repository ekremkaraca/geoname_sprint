class AddMapSettingsToQuizzes < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :map_latitude, :decimal, precision: 10, scale: 6
    add_column :quizzes, :map_longitude, :decimal, precision: 10, scale: 6
    add_column :quizzes, :map_zoom, :integer, default: 6, null: false
  end
end
