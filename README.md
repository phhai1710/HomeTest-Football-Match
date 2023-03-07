# Football Matches App MVVM with Combine + CoreData

App with a single page that loads a list of matches and teams. The user can view previous matches and watch highlights as well as view upcoming matches with the reminder schedule ability.

Implementing MVVM concept with Combine and using CoreData for offline usage. 

## Assignment
A detailed assignment can be found in [Assignment](https://github.com/phhai1710/HomeTest-Football-Match/wiki/Assignment).


## Usage

- Open `FootballMatches.xcodeproj`
- Waiting for Package dependencies downloaded

## Detail overview

To enforce modularity, the application is separated by `Domain`, `Platform` and `FootballMatches(Application)`.

### Domain
The `Domain` is basically about app's logic. It will not depend on UIKit and external frameworks(In this example, for demo purpose, it depends on Combine framework, but it shouldn't)

Entities are implemented as Swift value types

DataSource are protocols which do job related to fetch data. There are 2 types of data source: 
* Local data source - which the data will be stored in device storage
* Remote data source - which the data will be stored in the remote server.

### Platform
The `Platform` is a concrete implementation of the `Domain` in a specific platform like iOS. For example:
- Local DataSource implementation is CoreData, but we can use do implementation for Realm as well. This project separates the Core Data entity and Domain entity to avoid coupling. There are `DomainConvertible` and `CoreDataRepresentable` for the conversion between those entities. These files will be in `Platform` layer, because 'Platform' will depends on `Domain`, not vice versa.
- Remote Data source implementation is URLSession

In Services directory, there are 2 services for Core Data and URLSession. They contain initial implementation/configuration of their own to be used in Local data source and Remote data source.

### Application
In the current example, `Application` is implemented with the MVVM pattern and the use of Combine

### External Frameworks
This project uses some external frameworks to make development easier:
- SnapKit: DSL to make Auto Layout easy
- Kingfisher: Downloading and caching images
- JGProgressHUD: An elegant and simple progress HUD 

## TODO:
Due to the limited time, the project cannot be completed completely. There are still some practices that can be applied:
* Implementing Coordinator for MVVM-C
* Detaching Combine from Domain. Domain should be pure Closure and there will be a convertion to transform Closure to Publisher
* Applying Service Locator pattern
* Avoiding using Singleton
* Splitting CalendarManager by CalendarServiceProtocol and CalendarService then move to Domain and Data layer
* Should have a CoreData table to store scheduled event in calendar. It will be more guaranteed to delete sheduled event as well as to know which matches has been scheduled.
* Finishing UnitTest for remaining classes
* Fixing TODOs in code
