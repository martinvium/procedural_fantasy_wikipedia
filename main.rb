require "securerandom"

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100
NUM_FACTIONS = 3
CITY_POPULATION_THRESHOLD = 50
NUM_SEASONS = 100
CREATURE_SPAWN_RATE = 0.9

Faction = Struct.new(:name)
Tile = Struct.new(:terrain, :name, :population, :faction, :x, :y)
Actor = Struct.new(:race, :name, :alignment, :faction, :tile)
Race = Struct.new(:name, :description)
City = Struct.new(:name, :tile)
Season = Struct.new(:name)
Event = Struct.new(:title)

INDEPENDANT = Faction.new("independant")

SEASONS = [
  Season.new("Summer"),
  Season.new("Fall"),
  Season.new("Winter"),
  Season.new("Spring"),
]

CREATURE_EVENTS = [
  lambda { |factions, tile, a|
    b = new_hero(factions.sample, tile)
    generate_combat_event(a, b)
  }
]

def random_name
  SecureRandom.uuid
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
    Faction.new(random_name)
  end
end

def generate_tiles(factions, width, height)
  (0...width).map do |x|
    (0...height).map do |y|
      Tile.new(:grassland, random_name, generate_population, factions.sample, x, y)
    end
  end
end

def new_creature(tile)
  Actor.new(random_race, random_name, :evil, INDEPENDANT, tile)
end

def new_hero(faction, tile)
  Actor.new(random_race, random_name, :good, faction, tile)
end

def generate_creatures(tiles, chance_to_spawn)
  tiles.flatten.map { |tile|
    new_creature(tile) if rand > chance_to_spawn
  }.compact
end

def generate_cities(tiles, threshold)
  tiles.flatten.map do |tile|
    City.new(random_name, tile) if tile.population > threshold
  end
end

def generate_seasons(num_seasons)
  (0...num_seasons).map { |i| SEASONS[i % 4] }
end

def world_events(season)
  [
    Event.new("Season changed: #{season.name}")
  ]
end

def generate_combat_event(a, b)
  winner, looser = [a, b].shuffle
  Event.new("#{winner.name} (#{winner.race.name}) killed #{looser.name} (#{looser.race.name})")
end

def creature_events(creatures, factions)
  creatures.map do |creature|
    CREATURE_EVENTS.sample.call(factions, creature.tile, creature)
  end
end

def main
  factions = generate_factions(NUM_FACTIONS)
  tiles = generate_tiles(factions, GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, CREATURE_SPAWN_RATE)
  generate_cities(tiles, CITY_POPULATION_THRESHOLD)

  generate_seasons(NUM_SEASONS).map { |season|
    world_events(season) + creature_events(creatures, factions)
  }.flatten
end
