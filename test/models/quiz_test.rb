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

  test "to_param returns slug" do
    quiz = quizzes(:bulgaria)

    assert_equal "bulgaria-cities", quiz.to_param
  end

  test "rejects invalid slug format" do
    quiz = Quiz.new(
      title: "Bad Slug",
      slug: "Bad Slug!",
      region: "Test",
      duration_seconds: 300
    )

    assert_not quiz.valid?
  end

  test "city_guess_lookup includes aliases" do
    lookup = quizzes(:bulgaria).city_guess_lookup

    assert_equal(
      "haskovo",
      lookup["haskoy"]
    )
  end

  test "city_guess_lookup includes canonical names" do
    lookup = quizzes(:bulgaria).city_guess_lookup

    assert_equal(
      "haskovo",
      lookup["haskovo"]
    )
  end

  test "city_count returns number of cities" do
    quiz = quizzes(:bulgaria)

    assert_equal 3, quiz.city_count
  end

  test "city_lookup maps normalized names" do
    lookup = quizzes(:bulgaria)
      .city_lookup

    assert_equal "Sofia",
      lookup["sofia"]
  end
end
