require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  test "index responds successfully" do
    get root_path

    assert_response :success
  end

  test "show responds successfully" do
    quiz = quizzes(:bulgaria)

    get quiz_path(quiz.slug)

    assert_response :success
  end
end
