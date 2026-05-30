require "application_system_test_case"

class QuizGameplaysTest < ApplicationSystemTestCase
  test "player can guess a city by canonical name" do
    visit quiz_path(quizzes(:bulgaria))

    fill_in "Enter a city...", with: "Sofia"
    send_keys :enter

    assert_text "Found: 1"
    assert_text "✓ Sofia"
  end

  test "player can guess a city by alias" do
    visit quiz_path(quizzes(:bulgaria))

    fill_in "City guess", with: "Haskoy"
    send_keys :enter

    assert_text "Found: 1"
    assert_text "✓ Haskovo"
  end

  test "duplicate guesses do not increment count" do
    visit quiz_path(quizzes(:bulgaria))

    fill_in "City guess", with: "Sofia"
    send_keys :enter

    fill_in "City guess", with: "Sofia"
    send_keys :enter

    assert_text "Found: 1"
    assert_selector "li", text: "✓ Sofia", count: 1
  end

  test "invalid guesses are ignored" do
    visit quiz_path(quizzes(:bulgaria))

    fill_in "City guess", with: "Atlantis"
    send_keys :enter

    assert_text "Found: 0"
    assert_no_text "✓ Atlantis"
  end

  test "quiz completes when all cities are found" do
    visit quiz_path(quizzes(:bulgaria))

    accept_alert do
      %w[Sofia Varna Haskoy].each do |guess|
        fill_in "City guess", with: guess
        send_keys :enter
      end
    end

    assert_field "City guess", disabled: true
    assert_text "Found: 3"
  end

  test "quiz expires when timer reaches zero" do
    visit quiz_path(quizzes(:bulgaria_short))

    assert_text "Time left: 00:03"

    accept_alert do
      sleep 4
    end

    assert_field "City guess", disabled: true
  end
end
