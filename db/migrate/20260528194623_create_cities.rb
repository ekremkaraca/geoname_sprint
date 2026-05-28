class CreateCities < ActiveRecord::Migration[8.1]
  def change
    create_table :cities do |t|
      t.references :quiz, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.decimal :latitude, null: false, precision: 10, scale: 6
      t.decimal :longitude, null: false, precision: 10, scale: 6
      t.integer :population
      t.jsonb :aliases, null: false, default: []

      t.index [ :quiz_id, :normalized_name ], unique: true

      t.timestamps
    end
  end
end
