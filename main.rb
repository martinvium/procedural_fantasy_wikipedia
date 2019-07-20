require "securerandom"
require_relative "generators"
require_relative "actions"

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100
NUM_FACTIONS = 3
SITE_POP_THRESHOLD = 50
NUM_SEASONS = 8
CREATURE_SPAWN_RATE = 0.9

Faction = Struct.new(:name)
Tile = Struct.new(:terrain, :name, :population, :faction, :x, :y)
Actor = Struct.new(:race, :name, :alignment, :faction, :tile, :dead_at, :confined_at) {
  def active?
    dead_at.nil? && confined_at.nil?
  end

  def dead?
    dead_at != nil
  end
}

Race = Struct.new(:name, :description)
Site = Struct.new(:name, :tile) {
  def tile?(other_tile)
    return false if other_tile.nil?
    return false if tile.nil?

    other_tile === tile
  end
}
Season = Struct.new(:name)
Event = Struct.new(:title)
World = Struct.new(:factions, :tiles, :sites, :heroes, :creatures)

INDEPENDANT = Faction.new("independant")

SEASONS = [
  Season.new("Summer"),
  Season.new("Fall"),
  Season.new("Winter"),
  Season.new("Spring"),
]

CREATURE_ACTIONS = [
  method(:ambush_action),
  method(:kidnap_action),
  method(:raze_site_action),
  method(:escape_confinement_action),
]

HERO_ACTIONS = [
  method(:escape_confinement_action),
]

def build_creature(options = {})
  Actor.new(generate_race, generate_name("creature"), :evil, INDEPENDANT, options.fetch(:tile))
end

def build_hero(options = {})
  Actor.new(generate_race, generate_name("hero"), :good, options.fetch(:faction), options.fetch(:tile))
end

def world_events(season)
  [
    Event.new("Season changed: #{season.name}"),
  ]
end

def creature_events(world, season)
  world.creatures.map { |creature|
    CREATURE_ACTIONS.sample.call(world, season, creature.tile, creature)
  }.compact
end

def main
  factions = generate_factions(NUM_FACTIONS)
  tiles = generate_tiles(factions, GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, CREATURE_SPAWN_RATE)
  sites = generate_sites(tiles, SITE_POP_THRESHOLD)
  heroes = []

  world = World.new(factions, tiles, sites, heroes, creatures)

  generate_seasons(NUM_SEASONS).map { |season|
    world_events(season) + creature_events(world, season)
  }.flatten
end

if $0 == __FILE__
  main.each do |event|
    puts event.title
  end
end
