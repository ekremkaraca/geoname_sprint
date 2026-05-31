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

  test "rejects negative population" do
    city = cities(:sofia)
    city.population = -1

    assert_not city.valid?
  end

  test "rejects duplicate aliases within same city" do
    city = cities(:haskovo)
    city.aliases = %w[ haskoy haskoy ]

    assert_not city.valid?
  end

  test "rejects aliases used by another city in same quiz" do
    city = cities(:varna)
    city.aliases = %w[ haskoy ]

    assert_not city.valid?
  end

  test "aliases must be an array" do
    city = cities(:haskovo)
    city.aliases = "haskoy"

    assert_not city.valid?
  end

  test "accepts latitude at boundary -90" do
    city = cities(:sofia)
    city.latitude = -90

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "accepts latitude at boundary 90" do
    city = cities(:sofia)
    city.latitude = 90

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "accepts longitude at boundary -180" do
    city = cities(:sofia)
    city.longitude = -180

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "accepts longitude at boundary 180" do
    city = cities(:sofia)
    city.longitude = 180

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "rejects latitude below -90" do
    city = cities(:sofia)
    city.latitude = -91

    assert_not city.valid?
    assert_includes city.errors[:latitude], "must be greater than or equal to -90"
  end

  test "rejects latitude above 90" do
    city = cities(:sofia)
    city.latitude = 91

    assert_not city.valid?
  end

  test "rejects longitude below -180" do
    city = cities(:sofia)
    city.longitude = -181

    assert_not city.valid?
    assert_includes city.errors[:longitude], "must be greater than or equal to -180"
  end

  test "rejects longitude above 180" do
    city = cities(:sofia)
    city.longitude = 181

    assert_not city.valid?
  end

  test "allows nil population" do
    city = cities(:sofia)
    city.population = nil

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "rejects nil aliases" do
    city = cities(:haskovo)
    city.aliases = nil

    assert_not city.valid?
    assert_includes city.errors[:aliases], "must be an array"
  end

  test "allows empty aliases array" do
    city = cities(:haskovo)
    city.aliases = []

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "rejects alias that conflicts with another city normalized name" do
    quiz = quizzes(:bulgaria)
    city = City.new(
      quiz: quiz,
      name: "New City",
      normalized_name: "new-city",
      latitude: 40.0,
      longitude: 25.0,
      aliases: %w[ sofia ]
    )

    assert_not city.valid?
    assert city.errors[:aliases].any? { |msg| msg.include?("must not conflict") }
  end

  test "accepts normalized_name that is same as another city alias" do
    quiz = quizzes(:bulgaria)
    city = City.new(
      quiz: quiz,
      name: "New City",
      normalized_name: "haskoy",
      latitude: 40.0,
      longitude: 25.0
    )

    assert city.valid?, city.errors.full_messages.to_sentence
  end

  test "requires normalized_name" do
    city = cities(:sofia)
    city.normalized_name = nil

    assert_not city.valid?
    assert_includes city.errors[:normalized_name], "can't be blank"
  end

  test "requires latitude" do
    city = cities(:sofia)
    city.latitude = nil

    assert_not city.valid?
    assert_includes city.errors[:latitude], "can't be blank"
  end

  test "requires longitude" do
    city = cities(:sofia)
    city.longitude = nil

    assert_not city.valid?
    assert_includes city.errors[:longitude], "can't be blank"
  end

  test "requires quiz association" do
    city = City.new(
      name: "Orphan City",
      normalized_name: "orphan-city",
      latitude: 40.0,
      longitude: 25.0
    )

    assert_not city.valid?
    assert_includes city.errors[:quiz], "must exist"
  end
end
