require "test_helper"

class CityTest < ActiveSupport::TestCase
  test "valid city" do
    city = cities(:sofia)

    assert city.valid?
  end

  test "requires name" do
    city = cities(:sofia)
    city.name = nil

    assert_not city.valid?
  end

  test "requires normalized name to be unique within quiz" do
    existing = cities(:sofia)

    city = City.new(
      quiz: existing.quiz,
      name: "Sofia Duplicate",
      normalized_name: existing.normalized_name,
      latitude: 42.7,
      longitude: 23.3
    )

    assert_not city.valid?
  end

  test "allows same normalized name in different quiz" do
    quiz = Quiz.create!(
      title: "Another Quiz",
      slug: "another-quiz",
      region: "Test",
      duration_seconds: 300
    )

    city = City.new(
      quiz: quiz,
      name: "Sofia",
      normalized_name: "sofia",
      latitude: 42.7,
      longitude: 23.3
    )

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "rejects invalid coordinates" do
    city = cities(:sofia)

    city.latitude = 999
    city.longitude = 999

    assert_not city.valid?
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
end
