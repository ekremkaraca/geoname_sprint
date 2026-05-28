require "test_helper"

class QuizTest < ActiveSupport::TestCase
  test "valid quiz" do
    quiz = Quiz.new(
      title: "Turkey Cities",
      slug: "turkey-cities",
      region: "Turkey",
      duration_seconds: 300
    )

    assert quiz.valid?
  end

  test "invalid quiz" do
    quiz = Quiz.new(
      title: "Invalid quiz",
      slug: "invalid-quiz",
      region: "Invalid",
      duration_seconds: 0
    )

    assert_not quiz.valid?
  end
end
