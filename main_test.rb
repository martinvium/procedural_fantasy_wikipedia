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
    tiles = [build_tile(population: 150)]
    assert_kind_of(City, generate_cities(tiles, 100).first)
  end

  def test_skips_city_when_below_threshold
    tiles = [build_tile(population: 50)]
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

  def test_world_events
    assert_equal(
      [Event.new("Season changed: Fall")],
      world_events(Season.new("Fall"))
    )
  end

  def test_creature_events
    tile = Tile.new
    tile.population = 1
    creature = new_creature(tile)
    world = build_world(factions: [INDEPENDANT], cities: [City.new("city-name", tile)])

    actual = creature_events([creature], world)

    assert_kind_of(Event, actual.first)
  end

  def test_main
    assert_operator(50, :<, main.count)
  end

  def build_tile(population:)
    Tile.new(:grassland, "tile name", population)
  end

  def build_world(options = {})
    World.new(
      options.fetch(:factions, []),
      options.fetch(:tiles, []),
      options.fetch(:cities, []),
      options.fetch(:heroes, []),
    )
  end
end
