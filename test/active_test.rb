require 'rubygems'
require 'test/unit'
require File.expand_path("../../lib/active_set", __FILE__)

class ActiveSetTest < Test::Unit::TestCase
  def setup
    @set = ActiveSet.new :lols, :prefix => 'active_test'
    @set.clear
    @key = @set.key
  end

  def test_adds_item
    assert_equal 0, @set.count
    assert !@set.include?('abc')
    @set.add 'abc'
    assert_equal 1, @set.count
    assert @set.include?('abc')
  end

  def test_adds_item_with_custom_time
    time = Time.local(2001)
    @set.add 'abc', time
    assert_equal time, @set.timestamp_for('abc')
  end

  def test_counts_items
    assert_equal 0, @set.count
    @set.add 'abc'
    assert_equal 1, @set.count
    @set.add 'def', Time.local(2001)
    assert_equal 2, @set.count
    @set.add 'abc'
    assert_equal 2, @set.count
    assert_equal 1, @set.count(Time.local(2002))
  end

  def test_trims_set
    @set.add 'abc'
    @set.add 'def', Time.local(2001)
    assert_equal 2, @set.count
    @set.trim
    assert_equal 1, @set.count
    assert @set.include?('abc')
  end
end
