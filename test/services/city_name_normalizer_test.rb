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
    assert_equal "new york", CityNameNormalizer.call("New    York")
  end

  test "normalizes ğ" do
    assert_equal "mugla", CityNameNormalizer.call("Muğla")
  end

  test "normalizes ö" do
    assert_equal "koycegiz", CityNameNormalizer.call("Köycegiz")
  end

  test "normalizes ü" do
    assert_equal "gurun", CityNameNormalizer.call("Gürün")
  end

  test "normalizes ı" do
    assert_equal "kinik", CityNameNormalizer.call("Kınık")
  end

  test "normalizes ş" do
    assert_equal "kusadasi", CityNameNormalizer.call("Kuşadasi")
  end

  test "normalizes ç" do
    assert_equal "canakkale", CityNameNormalizer.call("Çanakkale")
  end

  test "normalizes İ" do
    assert_equal "istanbul", CityNameNormalizer.call("İstanbul")
  end

  test "normalizes I" do
    assert_equal "isparta", CityNameNormalizer.call("Isparta")
  end
end
