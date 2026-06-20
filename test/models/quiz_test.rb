require "test_helper"

class QuizTest < ActiveSupport::TestCase
  test "valid quiz" do
    quiz = Quiz.new(
      title: "Turkey Cities",
      slug: "turkey-cities",
      region: "Turkey",
      duration_seconds: 300,
      map_latitude: 39.0,
      map_longitude: 35.0
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

  test "duration_minutes returns seconds divided by 60" do
    quiz = quizzes(:bulgaria)

    assert_equal 5, quiz.duration_minutes
  end

  test "normalized_city_names returns array of normalized names" do
    quiz = quizzes(:bulgaria)

    assert_equal %w[haskovo sofia varna],
      quiz.normalized_city_names.sort
  end

  test "city_coordinates returns name and coordinates" do
    coords = quizzes(:bulgaria).city_coordinates

    assert_equal "Sofia", coords["sofia"][:name]
    assert_equal 42.7, coords["sofia"][:latitude]
    assert_equal 23.33, coords["sofia"][:longitude]
  end

  test "all_normalized_city_names includes canonical and alias names" do
    names = quizzes(:bulgaria).all_normalized_city_names

    assert_includes names, "sofia"
    assert_includes names, "haskovo"
    assert_includes names, "haskoy"
  end

  test "map_center returns actual coordinates when set" do
    quiz = Quiz.new(map_latitude: 42.7, map_longitude: 23.33)

    assert_equal [ 42.7, 23.33 ], quiz.map_center
  end

  test "map_center falls back to default when nil" do
    quiz = Quiz.new(map_latitude: nil, map_longitude: nil)

    assert_equal [ 39.0, 35.0 ], quiz.map_center
  end

  test "map_zoom returns default zoom when nil" do
    quiz = Quiz.new(map_zoom: nil)

    assert_equal 6, quiz.map_zoom
  end

  test "rejects duration_seconds of zero" do
    quiz = Quiz.new(
      title: "Zero Duration",
      slug: "zero-duration",
      region: "Test",
      duration_seconds: 0
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:duration_seconds], "must be greater than 0"
  end

  test "rejects negative duration_seconds" do
    quiz = Quiz.new(
      title: "Negative Duration",
      slug: "negative-duration",
      region: "Test",
      duration_seconds: -10
    )

    assert_not quiz.valid?
  end

  test "rejects map_zoom of zero" do
    quiz = Quiz.new(
      title: "Zero Zoom",
      slug: "zero-zoom",
      region: "Test",
      duration_seconds: 300,
      map_zoom: 0
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:map_zoom], "must be greater than 0"
  end

  test "rejects negative map_zoom" do
    quiz = Quiz.new(
      title: "Negative Zoom",
      slug: "negative-zoom",
      region: "Test",
      duration_seconds: 300,
      map_zoom: -1
    )

    assert_not quiz.valid?
  end

  test "rejects out of range map_latitude" do
    quiz = Quiz.new(
      title: "Bad Lat",
      slug: "bad-lat",
      region: "Test",
      duration_seconds: 300,
      map_latitude: 91,
      map_zoom: 6
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:map_latitude], "must be less than or equal to 90"
  end

  test "rejects out of range map_longitude" do
    quiz = Quiz.new(
      title: "Bad Lng",
      slug: "bad-lng",
      region: "Test",
      duration_seconds: 300,
      map_longitude: 181,
      map_zoom: 6
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:map_longitude], "must be less than or equal to 180"
  end

  test "rejects duplicate slug" do
    quiz = Quiz.new(
      title: "Duplicate Slug",
      slug: "bulgaria-cities",
      region: "Test",
      duration_seconds: 300
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:slug], "has already been taken"
  end

  test "requires title" do
    quiz = Quiz.new(
      slug: "no-title",
      region: "Test",
      duration_seconds: 300
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:title], "can't be blank"
  end

  test "requires slug" do
    quiz = Quiz.new(
      title: "No Slug",
      region: "Test",
      duration_seconds: 300
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:slug], "can't be blank"
  end

  test "requires region" do
    quiz = Quiz.new(
      title: "No Region",
      slug: "no-region",
      duration_seconds: 300
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:region], "can't be blank"
  end

  test "requires duration_seconds" do
    quiz = Quiz.new(
      title: "No Duration",
      slug: "no-duration-#{Time.now.to_i}",
      region: "Test",
      duration_seconds: nil
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:duration_seconds], "can't be blank"
  end

  test "requires map_latitude" do
    quiz = Quiz.new(
      title: "No Latitude",
      slug: "no-latitude",
      region: "Test",
      duration_seconds: 300,
      map_longitude: 35.0
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:map_latitude], "can't be blank"
  end

  test "requires map_longitude" do
    quiz = Quiz.new(
      title: "No Longitude",
      slug: "no-longitude",
      region: "Test",
      duration_seconds: 300,
      map_latitude: 39.0
    )

    assert_not quiz.valid?
    assert_includes quiz.errors[:map_longitude], "can't be blank"
  end

  test "destroying quiz destroys associated cities" do
    quiz = quizzes(:bulgaria)
    city_ids = quiz.city_ids

    assert_difference "City.count", -3 do
      quiz.destroy
    end

    assert_empty City.where(id: city_ids)
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
