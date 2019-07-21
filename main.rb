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
Actor = Struct.new(:race, :name, :alignment, :faction, :tile, :dead_at, :confined_at, :state) {
  def active?
    dead_at.nil? && confined_at.nil?
  end

  def dead?
    dead_at != nil
  end
}

Race = Struct.new(:name, :description)
Site = Struct.new(:name, :tile) {}
Season = Struct.new(:name)
Event = Struct.new(:title)
World = Struct.new(:factions, :tiles, :sites, :actors)

INDEPENDANT = Faction.new("independant")

SEASONS = [
  Season.new("Summer"),
  Season.new("Fall"),
  Season.new("Winter"),
  Season.new("Spring"),
]

ACTOR_ACTIONS = {
  evil: [
    method(:ambush_action),
    method(:kidnap_action),
    method(:raze_site_action),
    method(:escape_confinement_action),
  ],
  good: [
    method(:escape_confinement_action),
    method(:rescue_confined_action),
  ],
}

def same_tile?(a, b)
  return false if a.nil? || b.nil?

  a === b
end

def build_creature(options = {})
  build_actor(
    race: generate_race,
    name: generate_name("creature"),
    alignment: :evil,
    faction: INDEPENDANT,
    tile: options.fetch(:tile),
    state: :searching
  )
end

def build_hero(options = {})
  build_actor(
    race: generate_race,
    name: generate_name("hero"),
    alignment: :good,
    faction: options.fetch(:faction),
    tile: options.fetch(:tile),
    state: options.fetch(:state)
  )
end

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

def world_events(season)
  [
    Event.new("Season changed: #{season.name}"),
  ]
end

def actor_events(world, season)
  world.actors.map { |actor|
    available_actions = ACTOR_ACTIONS.fetch(actor.alignment)
    action = available_actions.sample
    action.call(world, season, actor.tile, actor)
  }.compact
end

def main
  factions = generate_factions(NUM_FACTIONS)
  tiles = generate_tiles(factions, GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, CREATURE_SPAWN_RATE)
  sites = generate_sites(tiles, SITE_POP_THRESHOLD)

  world = World.new(factions, tiles, sites, creatures)

  generate_seasons(NUM_SEASONS).map { |season|
    world_events(season) + actor_events(world, season)
  }.flatten
end

if $0 == __FILE__
  main.each do |event|
    puts event.title
  end
end
