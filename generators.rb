def generate_name(prefix)
  "#{prefix}-#{SecureRandom.uuid}"
end

def generate_population
  return 0 if rand > 0.5

  rand(MAX_PEOPLE)
end

def generate_race
  Race.new(:monster, "head of a chicken, body of a squirrel and claws of a tiger")
end

def generate_factions(num_factions)
  (0...num_factions).map do
    Faction.new(generate_name("faction"))
  end
end

def generate_tiles(factions, width, height)
  (0...width).map do |x|
    (0...height).map do |y|
      Tile.new(:grassland, generate_name("tile"), generate_population, factions.sample, x, y)
    end
  end
end

def generate_creatures(tiles, chance_to_spawn)
  tiles.flatten.map { |tile|
    build_creature(tile: tile) if rand > chance_to_spawn
  }.compact
end

def generate_sites(tiles, threshold)
  tiles.flatten.map { |tile|
    Site.new(generate_name("site"), tile) if tile.population > threshold
  }.compact
end

def generate_seasons(num_seasons)
  (0...num_seasons).map { |i| SEASONS[i % 4] }
end
