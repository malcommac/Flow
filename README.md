<p align="center" >
  <img src="https://raw.githubusercontent.com/malcommac/Flow/develop/Assets/logo.png" width=300px height=230px alt="Flow" title="Flow">
</p>

[![Version](https://img.shields.io/cocoapods/v/FlowTables.svg?style=flat)](http://cocoadocs.org/docsets/FlowTables) [![License](https://img.shields.io/cocoapods/l/FlowTables.svg?style=flat)](http://cocoadocs.org/docsets/FlowTables) [![Platform](https://img.shields.io/cocoapods/p/FlowTables.svg?style=flat)](http://cocoadocs.org/docsets/FlowTables)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FlowTables.svg)](https://img.shields.io/cocoapods/v/FlowTables.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@danielemargutti-blue.svg?style=flat)](http://twitter.com/danielemargutti)

## Flow
### A new way to populate and manage UITableView

<p align="center" >★★ <b>Star me to help the project! </b> ★★</p>

<p align="center" ><a href="http://paypal.me/danielemargutti"><b>Support the project. Make a small donation.</b></a></p>
<p align="center" >Created by <a href="http://www.danielemargutti.com">Daniele Margutti</a> (<a href="http://www.twitter.com/danielemargutti">@danielemargutti</a>)</p>

## WHAT'S FLOW
Flow is a Swift lightweight library which help you to better manage content in UITableViews.
It's easy and fast, perfectly fits the type-safe nature of Swift.

**Say goodbye to `UITableViewDataSource` and `UITableViewDelegate`** : just declare and set your data, let Flow take care of all!

## WHAT YOU CAN DO

The following code is the only required to create a complete TableView which shows a list of some football players.
Each player is represented by a class (the model) called `PlayerModel`; the instance is represented into the tableview by the `PlayerCell` UITableViewCell subclass.


```swift
let players: [PlayerModel] = ... // your array of players
let rows = Row<PlayerCell>.create(players, { row in // create rows
row.onTap = { _, path in // reponds to tap on cells
  print("Tap on '\(row.item.fullName)'")
  return nil
}
tableManager.add(rows: rows) // just add them to the table
tableManager.reloadData()
```

A complete table in few lines of code; **feel amazing uh? Yeah it is**, and there's more:
You can handle tap events, customize editing, easy create custom footer and headers and manage the entire content simply as like it was an array!.

A complete article about this topic can be found here:
["Forget DataSource and Delegates: a new approach for UITableView"](http://danielemargutti.com/2017/08/28/forget-datasources-delegates-a-new-way-to-create-and-manage-uitableview)

## MAIN FEATURES
Main features of Flow includes:
* **Declare the content**: Decide cell's class, the model and use array-like methods to add/remove or manage rows into the table. No more data source, no more delegate, just plain understandable methods to manage what kind of data you want to display (auto animations included!).
* **Separation of concerns**: Let the cell do its damn job; passing represented item (model) to the cell you can add a layer of separation between your model, your view controller and the cell which represent the model itself. Stop doing cell population inside the `tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)` datasource function. Be [SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)).
* **Type-safe**: Describe your cell classes, the model to represent and let the library take care of you. Allocation and configuration is automatic: no more reuse identifier strings, no more dequeue operations, no more casts.
* **FP (Functional Programming) Style**. Cell configurations is easy; you can observe events and manage the behaviour of the cells in a functional style.
* **AutoLayout support**: Provide a simple mechanism to specify the height of a cell or leave the class decide the best one upon described constraints.
* **Animations**: Like `performBatchUpdates` of `UICollectionView` Flow manage automatically what kind of animations perform on the table as you change the layout.

## OTHER LIBRARIES YOU MAY LIKE

I'm also working on several other projects you may like.
Take a look below:

<p align="center" >

| Library         | Description                                      |
|-----------------|--------------------------------------------------|
| [**SwiftDate**](https://github.com/malcommac/SwiftDate)       | The best way to manage date/timezones in Swift   |
| [**Hydra**](https://github.com/malcommac/Hydra)           | Write better async code: async/await & promises  |
| [**SwiftRichString**](https://github.com/malcommac/SwiftRichString) | Elegant & Painless NSAttributedString in Swift   |
| [**SwiftLocation**](https://github.com/malcommac/SwiftLocation)   | Efficient location manager                       |
| [**Flow**](https://github.com/malcommac/Flow)            | The great way to create and manage tables in iOS |
| [**SwiftMsgPack**](https://github.com/malcommac/SwiftMsgPack)    | Fast/efficient msgPack encoder/decoder           |
</p>

* * *

## DOCUMENTATION

* [Main Architecture](#architecture)
* [Demo Application](#example)
  * [Create the `TableManager`](#create_tablemanager)
  * [Prepare a Cell (for Row)](#prepare_cell)
  * [Prepare a Row](#prepare_row)
  * [Prepare Rows for an array of model](#prepare_rows_array)
  * [Add Rows into the table](#add_rows)
  * [Create `Section` and manage header/footer](#create_section)
* [`UITableView` Animations](#table_animations)
* [Observe `Row`/Cell Events](#row_events)

<a name="architecture" />

### Main Architecture

Flow is composed by four different entities:
* **`TableManager`**: a single table manager is responsible to manage the content of a `UITableView` instance.
* **`Section`**: represent a section in table. It manages the list of rows and optional header and footer.
* **`Row`**: represent a single row in a section; a row is linked to a pair of objects: the model (any class; if not applicable `Void` is valid) and the cell (a subclass of the `UITableViewCell` conforms to `DeclarativeCell` protocol).
* **`SectionView`**: A section may show header/footer; these objects maybe simple `String` or custom views: `SectionView`. As for `Row`, `SectionView` is linked to a model and a view (subclass of `UITableViewHeaderFooterView`).

<a name="example" />

### Demo Application

A live working example can be found in [FlowDemoApp directory](https://github.com/malcommac/Flow/tree/develop/FlowDemoApp). It demostrates how to use Flow in a simple Login screen for a fake social network app. Check it out to see how Flow can really help you to simplify UITableView management.

<a name="create_tablemanager" />

#### Create the `TableManager`

In order to use Flow you must set the ownership of a `UITableView` instance to an instance of `TableManager`:

```swift
self.tableManager = TableManager(table: self.table!)
```

From now the `UITableView` instance is backed by Flow; every change (add/remove/move rows or sections) must be done by calling appropriate methods of the `TableManager` itself or any child `Section`/`Row`.

<a name="prepare_cell" />

#### Prepare a Cell (for Row)

A row is resposible to manage the model and its graphical representation (the cell instance).
To create a new `Row` instance you need to specify the model class received by the instance cell and the cell class to instantiate into the table.

While sometimes a model is not applicable (your cell maybe a simple static representation or its decorative), the cell class is mandatory.
The cell must be a subclass of `UITableViewCell` conforms to `DeclarativeCell` protocol.
This protocol defines at least two important properties:

- the model assocated with the Cell (`public typealias T = MyClass`)
- a method called right after the row's cell is dequeued (`public func configure(_: T, path: IndexPath)`)

This is an example of a `PlayerCell` which is responsible to display data for a single football player (class `PlayerModel`):

```swift
import UIKit
import Flow

public class PlayerCell: UITableViewCell, DeclarativeCell {
    // assign to the cell the model to be represented
    public typealias T = PlayerModel
    // if your cell has a fixed height you can set it directly at class level as below
    public static var defaultHeight: CGFloat? = 157.0

    // this func is called when a new instance of the cell is dequeued
    // and you need to fill the data with a model instance.
    public func configure(_ player: PlayerMode, path: IndexPath) {
      self.playerName.text = player.firstName
      self.playerLast.text = player.lastName
      self.playerImage.setURL(player.avatarURL)
      // ... and so on
    }
}
```

If your cell does not need of a model you can assign `public typealias T = Void`.

User interface of the cell can be made in two ways:
* **Prototype (only in Storyboards)**: create a new prototype cell, assign the class to your class (here `PlayerCell`) and set the `reuseIdentifier` in IB to the same name of the class (again `PlayerCell`). By default Flow uses as identifier of the cell the same name of the class itself (you can change it by overriding `reuseIdentifier` static property).
* **External XIB File**: create a new xib file with the same name of your cell class (here `PlayerCell.xib`) and drag an instance of `UITableViewCell` class as the only single top level object. Assign to it the name of your class and the `reuseIdentifier`.

Height of a cell can be set in differen ways:
* If cell has a fixed height you can set it at class level by adding `public static var defaultHeight: CGFloat? = ...` in your cell subclass.
* If cell is autosized you can evaluate the height in row configuration (see below) by providing a value into `estimatedHeight` or `evaluateEstimatedHeight()` function.


<a name="prepare_row" />

#### Prepare a Row

You can now create a new row to add into the table; a `Row` instance is created by passing the `DeclarativeCell` type and an instance of the model represented.

```swift
let ronaldo = PlayerModel("Christiano","Ronaldo",.forward)
...
let row_ronaldo = Row<PlayerCell>(model: ronaldo, { row in
	// ... configuration
})
```

If model is not applicable just pass `Void()` as model param.

Inside the callback you can configure the various aspect of the row behaviour and appearance.
All standard UITableView events can be overriden; a common event is `onDequeue`, called when `Row`'s linked cell instance is dequeued and displayed. Anoter one (`onTap`) allows you to perform an action on cell's tap event.
So, for example:

```swift
let row_ronaldo = Row<PlayerCell>(model: ronaldo, { row in
	row.onDequeue = { _ in
		row.cell?.fullNameLabel.text = ronaldo.fullName
		return nil // when nil is returned cell will be deselected automatically
	}
	row.onTap = { _ in
		print("Tapped cell")
	}
})
```

There are lots of other events you can set into the row configuration callback (`onDelete`,`onSelect`,`onDeselect`,`onShouldHighlit` and so on).

<a name="prepare_rows_array" />

#### Prepare Rows for an array of model

When you have an array of model instances to represent, one for each Row, you can use `create` shortcut.
The following code create an array of `Rows<PlayerCell>` where each row receive the relative item from `self.players` array.

```swift
let players_rows = Row<PlayerCell>.create(self.players)
```
<a name="add_rows" />

#### Add Rows into the table

Adding rows to a table is easy as call a simple `add` function.

```swift
self.tableManager.add(rows: players_rows) // add rows (by appending a new section)
self.tableManager.reloadData() // apply changes
```

(Remember: when you add rows without specifing a section a new section is created automatically for you).

**Please note**: when you apply a change to a table (by using `add`, `remove` or `move` functions, both for `Section` or `Row` instances) you must call the `reloadData()` function in order to reflect changes in UI.


If you want to apply changes using standard table's animations just call `update()` function; it allows you to specify a list of actions to perform. In this case `reloadData()` is called automatically for you and the engine evaluate what's changed automatically (inserted/moved/removed rows/section).

The following example add a new section at the end of the table and remove the first:

```swift
self.tableManager?.update(animation: .automatic, {
	self.tableManager?.insert(section: profileDetailSection, at: profileSection!.index! + 1)
	self.tableManager?.remove(sectionAt: 0)
})
```

<a name="create_section" />

#### Create `Section` and manage header/footer

If not specified sections are created automatically when you add rows into a table.
`Section` objects encapulate the following properties:

- `rows` list of rows (`RowProtocol`) inside the section
- `headerTitle` / `headerView` a plain header string or a custom header view (`SectionView`)
- `footerTitle` / `footerView` a plain footer string or a custom footer view (`SectionView`)

Creating a new section with rows is pretty simple:

```swift
let rowPlayers: [RowProtocol] = ...
let sectionPlayers = Section(id: SECTION_ID_PLAYERS, row: rowPlayers, headerTitle: "\(rowPlayers.count) PLAYERS")"
```

As like for `Row` even `Section` may have custom view for header or footer; in this case your custom header/footer must be an `UITableViewHeaderFooterView` subclass defined in a separate XIB file (**with the same name of the class**) which is conform to `DeclarativeView` protocol.
`DeclarativeView` protocol defines the model accepted by the custom view (as for `Row` you can use `Void` if not applicable).

For example:

```swift
import UIKit
import Flow

public class TeamSectionView: UITableViewHeaderFooterView, DeclarativeView {
 public typealias T = TeamModel // the model represented by the view, use `Void` if not applicable
	
 public static var defaultHeight: CGFloat? = 100
	
 public func configure(_ item: TeamModel, type: SectionType, section: Int) {
  self.sectionLabel?.text = item.name.uppercased()
 }
}
```

Now you can create custom view as header for section:


```swift
let realMadridSection = Section(teamPlayers, headerView: SectionView<TeamSectionView>(team))
self.tableManager.add(section: realMadridSection)
self.tableManager.reloadData()
```


<a name="table_animations" />

### `UITableView` animations

Flow fully supports animation for `UITableView` changes. As like for `UICollectionView` you will need to call a func which encapsulate the operations you want to apply.

In Flow it's called `update(animation: UITableViewRowAnimation, block: ((Void) -> (Void)))`.

Inside the block you can alter the sections of the table, remove or add rows and section or move things into other locations. At the end of the block Flow will take care to collect the animations needed to reflect applied changes both to the model and the UI and execute them.

You just need to remember only two things:

* **Deletes are processed before inserts in batch operations**. This means the indexes for the deletions are processed relative to the indexes of the collection view’s state before the batch operation, and the indexes for the insertions are processed relative to the indexes of the state after all the deletions in the batch operation.
* In order to make a correct refresh of the data, **insertion must be done in order of the row index**.

For example:

```swift
self.tableManager?.update(animation: .automatic, {
	self.tableManager?.remove(sectionAt: 1) // remove section 1
	self.tableManager?.add(row: newPlayer, in: self.tableManager?.section(atIndex: 0)) // add a new row in section 0
})
```
<a name="row_events" />

### Observe `Row`/Cell Events

Flow allows you to encapsulate the logic of your `UITableViewCell` instances directly in your `Row` objects. You can listen for `dequeue`, `tap`, manage `highlights` or `edit`... pratically everything you can do with plain tables, but more confortably.

All events are available and fully described into the `Row` class.
In this example you will see how to respond to the tap:

```swift
// Respond to tap on player's cells
let rows = Row<PlayerCell>.create(players, { row in
  row.onTap = { _,path in
  print("Tap on player at \(String(path.row)): '\(row.item.fullName)'")
    return nil
  }
})
```

All observable events are described in [API SDK](API_SDK.md).

* * *

## API SDK Documentation

Full method documentation is available both in source code and in API_SDK file.
Click here to read the [Full SDK Documentation](API_SDK.md).

## Installation

<a name="cocoapods" />

### Install via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like Flow in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.0.1+ is required to build Flow.

#### Install via Podfile

To integrate Flow into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
  use_frameworks!
  pod 'FlowTables'
end
```

Then, run the following command:

```bash
$ pod install
```

<a name="carthage" />

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Flow into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "malcommac/Flow"
```

Run `carthage` to build the framework and drag the built `Flow.framework` into your Xcode project.

## REQUIREMENTS & LICENSE
Flow minimum requirements are:
* iOS 8+
* Swift 4+ (Swift 3 is supported in [swift-3 branch](https://github.com/malcommac/Flow/tree/swift-3))

We are supporting both [CocoaPods](#cocoapods) and [Chartage](#carthage).

Flow was created and mantained by [Daniele Margutti](http://www.danielemargutti.com); you can contact me at [hello@danielemargutti.com](mailto://hello@danielemargutti.com) or on twitter at [@danielemargutti](http://www.twitter.com/danielemargutti).

This library is licensed under [MIT License](https://opensource.org/licenses/MIT).

If you are using it in your software:
* Add a notice in your credits/copyright box: `Flow for UITableViews - © 2017 Daniele Margutti - www.danielemargutti.com`
* *(optional but appreciated)* [Click here to report me](https://github.com/malcommac/flow/issues/new?labels[]=Share&labels[]=[Type]%20Share&title=I'm%20using%20your%20library%20in%20my%20software&body=Hi,%20I'm%20using%20your%20library%20in%20my%20software;%20you%20can%20found%20it%20at%20the%20following%20link:) **your app using Flow**.

## SUPPORT THE PROJECT
Creating and mantaining libraries takes time and as developer you know this better than anyone else.

If you want to contribuite to the development of this project or give to me a thanks please consider to make a small donation using PayPal:

**MAKE A SMALL DONATION** and support the project.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](http://paypal.me/danielemargutti)

