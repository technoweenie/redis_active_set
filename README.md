# Active Set

This tracks the number of active objects during a certain time period in
a Redis sorted set.  Object activity is defined by your application, and
is out of the scope of this library.

When an object is active, it gets added to a Redis set with a timestamp.

    set = ActiveSet.new(:objects)
    set.add(1, Time.now) # Time.now is default if no time is given.

This is equivalent to the following Redis command:

    ZADD active:objects 1305054408 "1"

We can count the number of items in the set:

    set.count # => 1
    # ZCARD active:objects

The set should be trimmed periodically so that old objects aren't
counted.

    set.trim(1302462660)
    # ZREMRANGEBYSCORE active:objects -inf (1302462660

If no trim date is given, 30 days is assumed.
