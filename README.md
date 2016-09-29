# GTObjectManager
GTObjectManager is a lightweight framework designed to easily create NSManagedObject subclasses without the normal hassle of dealing with CoreData. With GTObjectManager, you interact with NSManagedObjects using either GTObjectManager directly or through intelligent NSManagedObject subclasses. I created this framework when I wrote Trove, and have used it in all of my projects that utilize CoreData.

# Features
GTObjectManager allows for very simply and efficient code for creating, fetching, and deleting NSManagedObjects by subclass. GTObjectManager can be used independently, or all features can be wrapped into your NSManagedObject subclasses for easy abstraction (see the demo project for an example).

### Create
```Swift
// create a new Contact NSManagedObject entity with uninitialized attribute values
let contact = GTObjectManager.createObjectOfType(Contact)
```

### Fetch
```Swift
// returns an array containing all Contact NSManagedObject entities
let allContacts = GTObjectManager.fetchAllObjectsOfType(Contact.self)

// returns an array containing a sorted, filtered set of Contact entities matching the passed predicate
let searchResults = GTObjectManager.fetchAllObjectsOfType(Contact.self, predicate: compoundPredicate, sortDescriptors: sortDescriptors)
```

### Count
```Swift
// returns the number of all Contact NSManagedObject entities
// this is faster and more memory efficient if all you need is the count
let contactCount = GTObjectManager.countAllObjectsOfType(Contact.self)

// returns the number of Contact entities matching the passed predicate
let searchResultCount = GTObjectManager.countAllObjectsOfType(Contact.self, predicate: compoundPredicate)
```

### Delete
```Swift
// Deletes all Contact entities in searchResults
GTObjectManager.deleteObjects(searchResults)
```

# Setup
After adding the `GTObjectManager.swift` file into your project, setup your `AppDelegate` to conform to the `GTCoreDataIdentifiable` protocol. If you setup your project with core data, no changes should be necessary; your `AppDelegate` will automatically conform to the protocol.

```Swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GTCoreDataIdentifiable {
    // No extra changes needed
}
```

With any `NSManagedObject` subclass you create, it must conform to the `GTManagedObjectIdentifiable` protocol. The only function in this protocol is `managedObjectEntityName()`, a static function that returns the name of the entity the subclass is representing as defined in the `.xcdatamodel` file (this is usually just the name of your subclass).

```Swift
class Contact: NSManagedObject, GTManagedObjectIdentifiable {
    class func managedObjectEntityName() -> String {
        return "Contact"
    }
}
```

# Example
Check out the project included in this repo for an example of how GTObjectManager can be used to easily create a contacts application without the normal hassle of dealing with Core Data. The project shows off how to self-contain creation within NSManagedObject subclasses and how to easily filter and sort contacts directly through GTObjectManager
