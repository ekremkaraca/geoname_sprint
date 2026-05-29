class QuizzesController < ApplicationController
  def index
    @quizzes = Quiz
      .includes(:cities)
      .order(:title)
  end

  def show
    @quiz = Quiz
      .includes(:cities)
      .find_by!(slug: params[:slug])
  end
end
