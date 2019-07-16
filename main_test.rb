require "minitest/autorun"
require_relative "main"

class MainTest < Minitest::Test
  def test_generate_tiles
    assert_equal(16, generate_tiles([Faction.new], 4, 4).flatten.count)
  end

  def test_generate_creatures
    assert_kind_of(Actor, generate_creatures([Tile.new], 0).first)
  end

  def test_generate_creatures_for_nested_tiles
    assert_equal(2, generate_creatures([[Tile.new], [Tile.new]], 0).count)
  end

  def test_generate_factions
    assert_kind_of(Faction, generate_factions(1).first)
  end

  def test_generates_city
    tiles = [create_tile(population: 150)]
    assert_kind_of(City, generate_cities(tiles, 100).first)
  end

  def test_skips_city_when_below_threshold
    tiles = [create_tile(population: 50)]
    assert_nil(generate_cities(tiles, 100).first)
  end

  def test_generate_seasons
    assert_equal([
      Season.new("Summer"),
      Season.new("Fall"),
      Season.new("Winter"),
      Season.new("Spring"),
      Season.new("Summer"),
      Season.new("Fall"),
      Season.new("Winter"),
      Season.new("Spring"),
    ], generate_seasons(8))
  end

  def test_generate_events
    assert_equal([
      Event.new("Season changed: Summer"),
      Event.new("Season changed: Fall"),
    ], generate_events(2))
  end

  def test_main
    assert_equal(100, main.count)
  end

  def create_tile(population:)
    Tile.new(:grassland, "tile name", population)
  end
end
