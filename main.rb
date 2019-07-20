require "securerandom"

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100
NUM_FACTIONS = 3
SITE_POP_THRESHOLD = 50
NUM_SEASONS = 8
CREATURE_SPAWN_RATE = 0.9

Faction = Struct.new(:name)
Tile = Struct.new(:terrain, :name, :population, :faction, :x, :y)
Actor = Struct.new(:race, :name, :alignment, :faction, :tile)
Race = Struct.new(:name, :description)
Site = Struct.new(:name, :tile)
Season = Struct.new(:name)
Event = Struct.new(:title)
World = Struct.new(:factions, :tiles, :sites, :heroes)

INDEPENDANT = Faction.new("independant")

SEASONS = [
  Season.new("Summer"),
  Season.new("Fall"),
  Season.new("Winter"),
  Season.new("Spring"),
]

def ambush_action(world, tile, protagonist)
  subject = new_hero(world.factions.sample, tile)
  winner, looser = [protagonist, subject].shuffle
  Event.new("#{winner.name} killed #{looser.name} in combat")
end

def kidnap_action(world, tile, protagonist)
  subject = new_hero(world.factions.sample, tile)
  Event.new("#{subject.name} was kidnapped by #{protagonist.name}")
end

def raze_site_action(world, tile, protagonist)
  site = world.sites.find { |site| site.tile === tile }
  return if site.nil?

  Event.new("#{protagonist.name} attacked the site of #{site.name}, during the dark of night, and razed it to the ground")
end

CREATURE_ACTIONS = [
  method(:ambush_action),
  method(:kidnap_action),
  method(:raze_site_action),
]

def random_name(prefix)
  "#{prefix}-#{SecureRandom.uuid}"
end

def generate_population
  return 0 if rand > 0.5

  rand(MAX_PEOPLE)
end

def random_race
  Race.new(:monster, "head of a chicken, body of a squirrel and claws of a tiger")
end

def generate_factions(num_factions)
  (0...num_factions).map do
    Faction.new(random_name("faction"))
  end
end

def generate_tiles(factions, width, height)
  (0...width).map do |x|
    (0...height).map do |y|
      Tile.new(:grassland, random_name("tile"), generate_population, factions.sample, x, y)
    end
  end
end

def new_creature(tile)
  Actor.new(random_race, random_name("creature"), :evil, INDEPENDANT, tile)
end

def new_hero(faction, tile)
  Actor.new(random_race, random_name("hero"), :good, faction, tile)
end

def generate_creatures(tiles, chance_to_spawn)
  tiles.flatten.map { |tile|
    new_creature(tile) if rand > chance_to_spawn
  }.compact
end

def generate_sites(tiles, threshold)
  tiles.flatten.map { |tile|
    Site.new(random_name("site"), tile) if tile.population > threshold
  }.compact
end

def generate_seasons(num_seasons)
  (0...num_seasons).map { |i| SEASONS[i % 4] }
end

def world_events(season)
  [
    Event.new("Season changed: #{season.name}"),
  ]
end

def creature_events(creatures, world)
  creatures.map do |creature|
    CREATURE_ACTIONS.sample.call(world, creature.tile, creature)
  end.compact
end

def main
  factions = generate_factions(NUM_FACTIONS)
  tiles = generate_tiles(factions, GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, CREATURE_SPAWN_RATE)
  sites = generate_sites(tiles, SITE_POP_THRESHOLD)
  heroes = []

  world = World.new(factions, tiles, sites, heroes)

  generate_seasons(NUM_SEASONS).map { |season|
    world_events(season) + creature_events(creatures, world)
  }.flatten
end

if $0 == __FILE__
  main.each do |event|
    puts event.title
  end
end
