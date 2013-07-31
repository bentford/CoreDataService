# Core Data Service

A lightweight framework for using Core Data.

### Features

* Allows quick and easy queries without going through NSFetchRequest dance.
* Provides a global MOC for use on main thread.
* Provides easy way to use Core Data in a background thread.


### Background

I built this back in 2010 and have used it on many shipping projects.

### Status

The code is stable, but I'm in the process of simplifying the interface to make it less awkward.

Here is what I have planned for CoreDataService.h:

* remove the "doubled methods" in `CoreDataservice.h` by defaulting the global MOC when context parameter is nil.
* Allow passing in a class or string as the entity name.