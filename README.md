# Core Data Service

A lightweight framework for using Core Data.

### Features

* Allows quick and easy queries and abstracts away the `NSFetchRequest dance.
* Provides a global MOC for use on main thread.
* Provides background thread MOC and takes care of multi-threading CoreData.
* Detects and gives stack trace on CoreData multi-thread errors.
* More...


### Current Status

I built this back in 2010 and have used it on many shipping projects.

The code is stable, but I'm in the process of simplifying the interface.

Here is what I have planned for CoreDataService.h:

* remove the "doubled methods" in `CoreDataservice.h` by defaulting the global MOC when context parameter is nil.
* Allow passing in a class or string as the entity name.

Other Changes:

* simplify naming of method in GlobalPersistenceCoordinator.h and friends
* remove the migration stuff, it never worked (but definitely has potential)