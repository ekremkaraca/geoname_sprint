require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "index renders quiz title" do
    get root_path

    assert_response :success
    assert_includes response.body, quizzes(:bulgaria).title
  end

  test "show renders quiz details" do
    quiz = quizzes(:bulgaria)

    get quiz_path(quiz)

    assert_response :success
    assert_includes response.body, quiz.title
    assert_includes response.body, "Sofia"
  end

  test "show returns not found for unknown slug" do
    get quiz_path("unknown-quiz")

    assert_response :not_found
  end

  test "destroying quiz removes cities" do
    quiz = quizzes(:bulgaria)

    assert_difference(
      "City.count",
      -quiz.cities.count
    ) do
      quiz.destroy
    end
  end
end
