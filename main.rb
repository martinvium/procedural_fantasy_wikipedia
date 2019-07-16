require 'securerandom'

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100
NUM_FACTIONS = 3
CITY_POPULATION_THRESHOLD = 50

Faction = Struct.new(:name)
Tile = Struct.new(:terrain, :name, :population, :faction, :x, :y)
Actor = Struct.new(:race, :name, :alignment, :faction, :tile)
Race = Struct.new(:name, :description)
City = Struct.new(:name, :tile)

INDEPENDANT = Faction.new("independant")

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
  0.upto(num_factions).map do
    Faction.new(random_name)
  end
end

def generate_tiles(factions, width, height)
  0.upto(width).map do |x|
    0.upto(height).map do |y|
      Tile.new(:grassland, random_name, generate_population, factions.sample, x, y)
    end
  end
end

def generate_creatures(tiles, chance_to_spawn)
  tiles.flatten.map do |tile|
    Actor.new(random_race, random_name, :evil, INDEPENDANT, tile) if rand > chance_to_spawn
  end.compact
end

def generate_cities(tiles, threshold)
  tiles.flatten.map do |tile|
    City.new(random_name, tile) if tile.population > threshold
  end
end

def pre_world
  factions = generate_factions(NUM_FACTIONS)
  tiles = generate_tiles(factions, GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, 0.8)
  generate_cities(tiles, CITY_POPULATION_THRESHOLD)
end

def step
  next_season
  generate_events
end

def output
  everything.each do
    write
  end
end

pp pre_world.count
