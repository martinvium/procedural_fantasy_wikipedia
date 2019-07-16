require 'securerandom'

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100

Tile = Struct.new(:terrain, :name, :num_people, :x, :y)
Actor = Struct.new(:race, :name, :alignment, :faction)
Race = Struct.new(:name, :description)

def random_name
  SecureRandom.uuid
end

def num_people
  return 0 if rand > 0.5

  rand(MAX_PEOPLE)
end

def random_race
  Race.new(:monster, "head of a chicken, body of a squirrel and claws of a tiger")
end

def generate_tiles
  0.upto(GRID_HEIGHT).map do |x|
    0.upto(GRID_WIDTH).map do |y|
      Tile.new(:grassland, random_name, num_people, x, y)
    end
  end
end

def generate_creatures(tiles)
  tiles.map do |row|
    row.map do |tile|
      Actor.new(random_race, random_name, :evil, :independant) if rand > 0.8
    end
  end.flatten.compact
end

def pre_world
  tiles = generate_tiles
  creatures = generate_creatures(tiles)
  return creatures
  #generate_civilizations
  #generate_communities
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
