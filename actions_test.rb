require "pry"
require "minitest/autorun"
require_relative "main"

class ActionsTest < Minitest::Test
  def test_ambush_action_returns_event
    world = build_simple_world
    season = Season.new("test-season")
    event = ambush_action(world, season, world.tiles.first, build_actor)
    assert_kind_of(Event, event)
  end

  def test_ambush_action_returns_nil_when_protagonist_is_inactive
    assert_nil ambush_action(nil, nil, nil, build_actor(dead_at: Season.new))
  end

  def test_raze_site_action_returns_event
    world = build_simple_world
    season = Season.new("test-season")
    event = raze_site_action(world, season, world.tiles.first, build_actor)
    assert_kind_of(Event, event)
  end

  def test_raze_site_action_returns_nil_when_protagonist_is_dead
    world = build_simple_world
    season = Season.new("test-season")
    assert_nil raze_site_action(world, season, world.tiles.first, build_actor(dead_at: Season.new))
  end

  def test_escape_confinement_action_returns_event
    event = escape_confinement_action(nil, nil, nil, build_actor(confined_at: Actor.new))
    assert_kind_of(Event, event)
  end

  def test_escape_confinement_action_returns_nil_when_protagonist_is_dead
    assert_nil escape_confinement_action(nil, nil, nil, build_actor(dead_at: Season.new))
  end

  private

  def build_actor(options = {})
    Actor.new(
      options[:face],
      options[:name],
      options[:alignment],
      options[:faction],
      options[:tile],
      options[:dead_at],
      options[:confined_at],
    )
  end

  def build_simple_world
    tile = build_tile(pop: 1)

    build_world(
      factions: [INDEPENDANT],
      tiles: [tile],
      sites: [Site.new("site-name", tile)],
      creatures: [build_creature(tile: tile)]
    )
  end

  def build_tile(pop:)
    Tile.new(:grassland, "tile name", pop)
  end

  def build_world(options = {})
    World.new(
      options.fetch(:factions, []),
      options.fetch(:tiles, []),
      options.fetch(:sites, []),
      options.fetch(:heroes, []),
      options.fetch(:creatures, []),
    )
  end
end
