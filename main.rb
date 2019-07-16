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

def generate_tiles(width, height)
  0.upto(width).map do |x|
    0.upto(height).map do |y|
      Tile.new(:grassland, random_name, num_people, x, y)
    end
  end
end

def generate_creatures(tiles, chance_to_spawn)
  tiles.flatten.map do |_tile|
    Actor.new(random_race, random_name, :evil, :independant) if rand > chance_to_spawn
  end.compact
end

def pre_world
  tiles = generate_tiles(GRID_WIDTH, GRID_HEIGHT)
  creatures = generate_creatures(tiles, 0.8)
  # generate_civilizations
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
