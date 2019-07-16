require "minitest/autorun"
require_relative "main"

class MainTest < Minitest::Test
  def test_generate_tiles
    assert_equal(25, generate_tiles(4, 4).flatten.count)
  end

  def test_generate_creatures
    assert_kind_of(Actor, generate_creatures([Tile.new], 0).first)
  end

  def test_generate_creatures_for_nested_tiles
    assert_equal(2, generate_creatures([[Tile.new], [Tile.new]], 0).count)
  end

  def test_generate_civilizations

  end
end
