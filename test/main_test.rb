require "pry"
require "minitest/autorun"
require_relative "../main"

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

  def test_generates_site
    tiles = [build_tile(population: 150)]
    assert_kind_of(Site, generate_sites(tiles, 100).first)
  end

  def test_skips_site_when_below_threshold
    tiles = [build_tile(population: 50)]
    assert_nil(generate_sites(tiles, 100).first)
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

  def test_main
    seed = 1234
    assert_operator(20, :<, main(seed).count)
  end

  def test_valid_move_positions_returns_all_options
    assert_equal(
      [
        Position.new(4, 5),
        Position.new(6, 5),
        Position.new(5, 4),
        Position.new(5, 6),
      ],
      valid_move_positions(Position.new(5, 5))
    )
  end

  def test_valid_move_positions_returns_only_unique_clamped_max_values
    assert_equal(
      [
        Position.new(10, 11),
        Position.new(11, 10),
      ],
      valid_move_positions(Position.new(GRID_WIDTH - 1, GRID_HEIGHT - 1))
    )
  end

  def test_valid_move_positions_returns_only_unique_clamped_min_values
    assert_equal(
      [
        Position.new(1, 0),
        Position.new(0, 1),
      ],
      valid_move_positions(Position.new(0, 0))
    )
  end

  private

  def build_tile(population:)
    Tile.new(:grassland, "tile name", population)
  end

  def build_simple_world
    tile = Tile.new("test-tile")
    tile.population = 1

    build_world(
      factions: [INDEPENDANT],
      sites: [Site.new("site-name", tile)],
      creatures: [build_creature(tile: tile)]
    )
  end

  def build_world(options = {})
    World.new(
      options.fetch(:factions, []),
      options.fetch(:tiles, []),
      options.fetch(:sites, []),
      options.fetch(:actors, []),
    )
  end
end
