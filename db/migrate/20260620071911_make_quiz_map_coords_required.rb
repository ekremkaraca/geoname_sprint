class MakeQuizMapCoordsRequired < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        Quiz.where(map_latitude: nil).update_all(map_latitude: 39.0)
        Quiz.where(map_longitude: nil).update_all(map_longitude: 35.0)
      end
    end

    change_column_null :quizzes, :map_latitude, false
    change_column_null :quizzes, :map_longitude, false
  end
end
