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

  test "show renders the quiz wiring needed for city guesses and the timer" do
    quiz = quizzes(:bulgaria)

    get quiz_path(quiz.slug)

    assert_response :success
    assert_select "div[data-controller='quiz']"
    assert_select "[data-quiz-target='count']", text: "0"
    assert_select "[data-quiz-target='timer']", text: "05:00"
    assert_select "[data-quiz-target='results']"

    quiz_root = response.parsed_body.at_css("div[data-controller='quiz']")
    guess_lookup = JSON.parse(quiz_root["data-quiz-guess-lookup-value"])

    assert_equal "haskovo", guess_lookup["haskoy"]
  end
end
