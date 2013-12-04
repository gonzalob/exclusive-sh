# Exclusive Script Execution Wrapper #

## Usage ##

A task can set locks, wait on locks, both or none.
By setting a wait, a dependency is created. That task will not execute when 
another task that sets that lock is running.

Runing the script with -h will display the help page, which will most 
certainly be more up-to-date than a README file ;-)

## Configuration ##

Any command line argument has a corresponding configuration variable, 
which can be defined in /etc/default/exclusive-sh for convenience.

# A word of caution #

Each execution assumes it completely owns the lock names it should set. This 
means it won't check if said lock exists, unless it's waiting for it as well.
Running two processes that share a lock will cause the lock to be released 
as soon as the _first_ process ends, not the last.

# License #
This software is licensed under the [GPLv3](http://www.gnu.org/licenses/gpl.txt).

