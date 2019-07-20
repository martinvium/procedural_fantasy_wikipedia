def ambush_action(world, season, tile, protagonist)
  return unless protagonist.active?

  subject = build_hero(faction: world.factions.sample, tile: tile)
  winner, looser = [protagonist, subject].shuffle
  looser.dead_at = season
  Event.new("#{winner.name} killed #{looser.name} in combat")
end

def kidnap_action(world, season, tile, protagonist)
  return unless protagonist.active?

  subject = build_hero(faction: world.factions.sample, tile: tile)
  subject.confined_at = protagonist
  Event.new("#{subject.name} was kidnapped by #{protagonist.name}")
end

def raze_site_action(world, season, tile, protagonist)
  return unless protagonist.active?

  site = world.sites.find { |site| site.tile?(tile) }
  return if site.nil?

  Event.new("#{protagonist.name} attacked the site of #{site.name}, during the dark of night, and razed it to the ground")
end

def escape_confinement_action(world, season, tile, protagonist)
  return if protagonist.dead?
  return if protagonist.confined_at.nil?

  was_confined_at = protagonist.confined_at
  protagonist.confined_at = nil
  Event.new("#{protagonist.name} escaped confinement at #{was_confined_at}")
end
