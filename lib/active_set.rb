require 'redis'

class ActiveSet
  VERSION = "0.1.0"
  SECONDS_PER_DAY = 86400

  attr_reader :key

  # Initializes a new Set of active objects.
  #
  # name    - String name to identify this ActiveSet.
  # options - Hash of options.
  #           :prefix - String prefix used to namespace the Redis key.
  #           :days   - Default Fixnum of days of items to allow in the
  #                     set.  Default to 30.
  #           :sec    - Fixnum of seconds of items to allow in the set.
  #                     Defaults to using MATH to calculate seconds in
  #                     30 days.
  #           :redis  - An existing Redis connection.  If not set, the
  #                     rest of this options Hash is used to initialize
  #                     a new Redis connection.
  def initialize(name, options = {})
    @name = name
    @prefix  = options.delete(:prefix) || :active
    @days    = options.delete(:days)   || 30
    @sec     = options.delete(:sec)    || (SECONDS_PER_DAY * @days)
    @redis   = options.delete(:redis)
    @key     = "#{@prefix}:#{@name}"
    @redis ||= Redis.new(options)
  end

  # Public: Adds a new object to the Set.
  #
  # entry - The String identifier of the object.
  # time  - Optional Time specifying when the object was last active.
  #
  # Returns nothing.
  def add(entry, time = Time.now)
    @redis.zadd(@key, time.to_i, entry)
  end

  # Public: Checks to see if the object is in the Set.
  #
  # entry - The String identifier of the object.
  #
  # Returns true if the object is in the set, or false.
  def include?(entry)
    !@redis.zscore(@key, entry).nil?
  end

  # Public: Gets the timestamp for when the given object was active.
  #
  # entry - The String identifier of the object.
  #
  # Returns the Time the object was last active, or nil.
  def timestamp_for(entry)
    sec = @redis.zscore(@key, entry)
    sec ? Time.at(sec.to_i) : nil
  end

  # Public: Counts the number of objects in the set.
  #
  # since - An optional Time to specify the cutoff time to
  #         count.  If provided, any object updated since the timestamp
  #         is counted.
  #
  # Returns a Fixnum.
  def count(since = nil)
    (since ?
      @redis.zcount(@key, since.to_i, "+inf") :
      @redis.zcard(@key)).to_i
  end

  # Public: Trims the Set.
  #
  # time - Optional Time specifying the earliest cutoff point.  Any
  #        object with a later timestamp is purged.
  #
  # Returns nothing.
  def trim(time = earliest_time)
    @redis.zremrangebyscore(@key, "-inf", "(#{time.to_i}")
  end

  # Public: Clears the Set.
  #
  # Returns nothing.
  def clear
    @redis.del(@key)
  end

  # Calculates the earliest time used as a cutoff point for #trim.
  #
  # Returns Fixnum seconds.
  def earliest_time
    Time.now.to_i - @sec
  end
end
