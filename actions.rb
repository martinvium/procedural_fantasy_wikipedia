def ambush_action(world, season, tile, protagonist)
  return unless protagonist.active?

  subject = (world.actors << build_hero(faction: world.factions.sample, tile: tile, state: :exploring)).last
  winner, looser = [protagonist, subject].shuffle
  looser.dead_at = season
  Event.new("#{winner.name} killed #{looser.name} in combat")
end

def kidnap_action(world, season, tile, protagonist)
  return unless protagonist.active?

  subject = (world.actors << build_hero(faction: world.factions.sample, tile: tile, state: :resting)).last
  subject.confined_at = protagonist
  subject.state = :resting
  Event.new("#{subject.name} was kidnapped by #{protagonist.name}")
end

def raze_site_action(world, season, tile, protagonist)
  return unless protagonist.active?

  site = world.sites.find { |site| same_tile?(site.tile, tile) }
  return if site.nil?

  Event.new("#{protagonist.name} attacked the site of #{site.name}, during the dark of night, and razed it to the ground")
end

def escape_confinement_action(world, season, tile, protagonist)
  return if protagonist.dead?
  return if protagonist.confined_at.nil?

  was_confined_at = protagonist.confined_at
  protagonist.confined_at = nil
  protagonist.state = :fleeing
  Event.new("#{protagonist.name} escaped confinement at #{was_confined_at.name}")
end

def rescue_confined_action(world, season, tile, protagonist)
  return unless protagonist.active?

  subjects = world.actors.select { |subject| same_tile?(subject.tile, tile) }
  subject = subjects.find { |subject| !subject.confined_at.nil? }
  return if subject.nil?

  was_confined_at = protagonist.confined_at
  subject.confined_at = nil
  subject.state = :exploring
  Event.new("#{protagonist.name} rescued #{subject.name} from confinement at #{was_confined_at}")
end

def build_lair_action(world, season, tile, protagonist)
  return unless protagonist.active?

  existing_site = world.sites.find { |site| same_tile?(site.tile, tile) }
  return unless existing_site.nil?

  world.sites << build_site(tile: tile, founded_by: protagonist)
  protagonist.state = :resting

  # to ambush, was trapped, was placed by evil mastermind
  Event.new("#{protagonist.name} found a good spot to settle down")
end

def assist_site_action(world, season, tile, protagonist)
  # not sure what this is...
  raise "todo"
end

def flee_action(world, season, tile, protagonist)
  return unless protagonist.active?
  return unless protagonist.state == :fleeing

  site = world.sites.find { |site| same_tile?(site.tile, tile) }
  if site.nil?
    new_position = valid_move_positions(Position.new(protagonist.tile.x, protagonist.tile.y)).sample
    protagonist.tile = world.tiles.fetch(new_position.x).fetch(new_position.y)
    return nil
  end

  protagonist.state = :exploring
  Event.new("#{protagonist.name} found a safe place to stop fleeing and regain their strength")
end
