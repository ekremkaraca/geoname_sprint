require "test_helper"

class CityNameNormalizerTest < ActiveSupport::TestCase
  test "normalizes Turkish characters" do
    assert_equal "istanbul", CityNameNormalizer.call("İstanbul")
    assert_equal "canakkale", CityNameNormalizer.call("Çanakkale")
    assert_equal "sanliurfa", CityNameNormalizer.call("Şanlıurfa")
  end

  test "strips extra spaces" do
    assert_equal "izmir", CityNameNormalizer.call("  İzmir  ")
  end

  test "strips punctuation" do
    assert_equal "canakkale", CityNameNormalizer.call("Çanakkale.")
  end

  test "collapses internal spaces" do
    assert_equal "istanbul", CityNameNormalizer.call("Istanbul  ")
  end
end
