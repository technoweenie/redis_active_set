# Active Set

This tracks the number of active objects during a certain time period in
a Redis sorted set.  Object activity is defined by your application, and
is out of the scope of this library.

## INSTALL

    gem install active_set

## USAGE

When an object is active, it gets added to a Redis set with a timestamp.

    set = ActiveSet.new(:objects)
    set.add(1, Time.now) # Time.now is default if no time is given.

This is equivalent to the following Redis command:

    ZADD active:objects 1305054408 "1"

We can count the number of items in the set:

    set.count # => 1
    # ZCARD active:objects

You can also count the active items since a given time:

    set.count(1302462660)
    # ZCOUNT active:objects 1302462660 +inf

The set should be trimmed periodically so that old objects aren't
counted.

    set.trim(1302462660)
    # ZREMRANGEBYSCORE active:objects -inf (1302462660

If no trim date is given, 30 days is assumed.

You can also check if an object is in the active set, and get it's last
timestamp.

    set.include?(1)
    set.timestamp_for(1) # => Time
    # ZSCORE active:objects "1"

## Contribute

If you'd like to hack on ActiveSet, start by forking the repo on GitHub:

`https://github.com/technoweenie/redis_active_set`

The best way to get your changes merged back into core is as follows:

* Clone down your fork
* Create a thoughtfully named topic branch to contain your change
* Hack away
* Add tests and make sure everything still passes by running rake
* If you are adding new functionality, document it in the README
* Do not change the version number, I will do that on my end
* If necessary, rebase your commits into logical chunks, without errors
* Push the branch up to GitHub
* Send a pull request to the `technoweenie/redis_active_set` project.

