require 'securerandom'

GRID_HEIGHT = 12
GRID_WIDTH = 12
MAX_PEOPLE = 100

Tile = Struct.new(:type, :name, :num_people)

def random_name
  SecureRandom.uuid
end

def num_people
  return 0 if rand > 0.5

  rand(MAX_PEOPLE)
end

def generate_locations
  0.upto(GRID_HEIGHT).map do
    0.upto(GRID_WIDTH).map do
      Tile.new(
        :grassland,
        random_name,
        num_people
      )
    end
  end
end

def pre_world
  locations = generate_locations

  return locations
  generate_creatures
  generate_civilizations
  generate_communities
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

pp pre_world.flatten.inspect
