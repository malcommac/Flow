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
* [Example](#example)
  * [Create the `TableManager`](#create_tablemanager)
  * [Create `UITableViewCell` cell](#create_cell)
  * [Design cell in Interface Builder](#create_cell_ib)
  * [Manage the size of the cell](#manage_cell_size)
  * [Create and add `Rows` to the table](#create_rows)
  * [Create `Section` and manage Header/Footer](#create_section)
* [`UITableView` Animations](#table_animations)
* [Observe `Row`/Cell Events](#row_events)

## API Doc

* [`TableManager` object](#api_tablemanager)
* [`Section` object](#api_section)
* [`Row` object](#api_row)

* * *

<a name="architecture" />

### Main Architecture

Flow basically is composed by four different entities:
* **`TableManager`**: a single table manager is responsible to manage the content of a `UITableView` instance.
* **`Section`**: represent a section of a table. It encapsulate the logic to manage rows into the section, custom header or footer.
* **`Row`**: represent a single row of the table; when you create a new row to insert into the table you will specify the class you want to use to represent it (a subclass of `UITableViewCell`) and the model which you are about to represent (any object you want).
* **`SectionView`**: if you want to create custom header/footer into the table you are using this class to create reusable views. As like for rows also `SectionView` are associated to a specific model to represent.

<a name="example" />

### Example

A live working example can be found in [FlowDemoApp directory](https://github.com/malcommac/Flow/tree/develop/FlowDemoApp). It demostrates how to use Flow in a simple Login screen for a fake social network app. Check it out to see how Flow can really help you to simplify UITableView management.

<a name="create_tablemanager" />

#### Create the `TableManager`

First of all you need to create your table manager.
You will create it (generally) in your view controller:

```swift
self.tableManager = TableManager(table: self.table!)
```

From now your `UITableView` instance is backed by Flow Table Manager; since now you will refer to it to manage the content you want to display (rows, sections, headers or footers).

<a name="create_cell" />

#### Create `UITableViewCell` cell

Suppose you want to represent a list of soccer players; you will have an array of players (suppose they are represented by `PlayerModel` class). Now you need to create an `UITableViewCell` subclass (`PlayerCell`) which represent this kind of data.
`PlayerCell` is a normal `UITableViewCell` which is conform to `DeclarativeCell` protocol which is needed to define some intrinsic properties of the cell itself.

```swift
import UIKit
import Flow

public class PlayerCell: UITableViewCell, DeclarativeCell {
    // assign to the cell the model to be represented
    public typealias T = PlayerModel

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

<a name="create_cell_ib" />

### Design cell in Interface Builder

You can create the UI of your cell in two different ways:
* **Using Storyboard**: create a new prototype cell, assign the class to your class (here `PlayerCell`) and set the `reuseIdentifier` in IB to the same name of the class (again `PlayerCell`). By default Flow uses as identifier of the cell the same name of the class itself (you can change it by overriding `reuseIdentifier` static property).
* **Manually**: create a new xib file with the same name of your cell class (here `PlayerCell.xib`) and drag an instance of `UITableViewCell` class as the only single top level object. Assign to it the name of your class and the `reuseIdentifier`.

Flow will take care of the load and dequeue of the instances for you!

<a name="manage_cell_size" />

### Manage the size of the cell

If your cell has a fixed height which does not change with the content of the model you want also implement the following static properties:

* `defaultHeight` (`CGFLoat`): return the height of the cell (if your cell is autosizing you can also return `UITableViewAutomaticDimension`)
* `estimatedHeight` (`CGFloat`): return estimated height (only for autosizing cells)

If your cell needs to evaluate the height based upon the content you can override the `evaluateRowHeight()` and/or `evaluateEstimatedHeight()` of your `Row` class (we'll see it later).

<a name="create_rows" />

### Create and add `Rows` to the table

As we said each section of the table is managed by a `Section` instance and each row by a `Row` instance.
When you add rows to a table manager you are creating a section automatically (unless you specify a destination `Section` or create a new `Section` with the rows).

Now let's suppose we want to create a section with our `[PlayerModel]` using the `PlayerCell` cell class.

```swift
let players_rows = Row<PlayerCell>.create(self.players)
```

We are telling the compiler to create a set of rows from `self.players` array and uses `PlayerCell` as backed `UITableViewCell` class.
Obviously you can also create a single row:

```swift
let row = Row<PlayerCell>(self.singlePlayer)
```

Now you can add rows to your table by using:

```swift
self.tableManager.add(rows: players_rows) // add rows (by appending a new section)
self.tableManager.reloadData() // apply changes
``` 

And that's all, your table is ready!

<a name="create_section" />

### Create `Section` and manage Header/Footer
If not specified sections are created automatically. You can however create a new `Section` instance and assign rows to it and customize the appearance of the header/footer.

Section header/footer view can be plain `String` objects (just assign the `headerTitle` or `footerTitle` of the `Section`) or custom `UITableViewHeaderFooterView`.

To create a new custom view just create your custom class which is conform to `DeclarativeView` protocol.

```swift
import UIKit
import Flow

public class TeamSectionView: UITableViewHeaderFooterView, DeclarativeView {
 public typealias T = TeamModel // the model represented by the view
	
 public static var defaultHeight: CGFloat? {
  return 100 // fixed height for view
 }
	
 public func configure(_ item: TeamModel, type: SectionType, section: Int) {
  self.sectionLabel?.text = item.name.uppercased()
 }
}
```

Now you need to create your own representation via Interface Builder.
Just create a `xib` file with the same name (`TeamSectionView.xib`) and drag a UIView as single top level object. Finally assign the class to your subclass (`TeamSectionView`).
Flow will take care of dequeue and load header/footer views automatically.

Now you are free to create your new section and assign your custom header:

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

All other events are described in [Row Events](row_events) section.

* * *

## API SDK Documentation

<a name="api_tablemanager" />

### `TableManager`

#### Initialize

| **Signature**                                                                | **Description**                                                                                                                                                                          |
|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `init(table: UITableView, estimateRowHeight: Bool)`                          | Initialize a new manager for a specific `UITableView` instance                                                                                                                           |                                                                                                                                                     |

#### Reload

| **Signature**                                                                | **Description**                                                                                                                                                                          |
|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `reloadData()`                                                               | Reload the data displayed by the managed table. Call it at the end of your operations in order to reflect made changes. Reload is not animated.                                          |
| `update(animation:block:)`                                                   | Allows to perform a batch of operations on table's sections and rows. At the end of the block animations are collected and executed to reflect into the UI changes applied to the model. |
| `reload(sectionWithID id: String, animation: UITableViewRowAnimation?)`      | Reload data for section with given identifier                                                                                                                                            |
| `reload(sectionsWithIDs ids: [String],,animation: UITableViewRowAnimation?)` | Reload data for sections with given identifiers. Non existing section are ignored.                                                                                                       |
| `reload(sections: [Section], animation: UITableViewRowAnimation?)`           | Reload data for given sections.                                                                                                                                                          |


#### Add Rows

| **Signature**                                       | **Description**                                                                                                                                                                                               |
|-----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `add(rows: [RowProtocol], in section: Section?)`    | Add rows to a section, if section is `nil` a new section is appened with rows at the end of table                                                                                                             |
| `add(rows: [RowProtocol], inSectionAt index: Int?)` | Add rows to a section specified at index (If `nil` is passed rows will be added to the last section of the table. If no sections are available, a new section with passed rows will be created automatically) |
| `add(row: RowProtocol, in section: Section? = nil)` | Add a new row into a section; if section is `nil` a new section is created and added at the end of table (is `section` is `nil` a new section is created and added at the end of the table).                  |
| `add(row: RowProtocol, inSectionAt index: Int?)`    | Add a new row into specified section (If `nil` is passed the last section is used as destination. if no sections are present into the table a new section with given row is created automatically).           |


#### Move/Insert/Replace Rows

| **Signature**                                                 | **Description**                                                                                                                       |
|---------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `move(row indexPath: IndexPath, to destIndexPath: IndexPath)` | Move a row in another position. This is a composed operation: first of all row is removed from source, then is added to the new path. |
| `insert(section: Section, at index: Int)`                     | Insert a section at specified index of the table.                                                                                     |
| `replace(sectionAt index: Int, with section: Section)`        | Replace an existing section with the new passed.                                                                                      |
| `remove(sectionAt index: Int)`                                | Remove an existing section at specified index.                                                                                        |
| `removeAll()`                                                 | Remove all the sections of the table.                                                                                                 |

#### Get section

| **Signature**                           | **Description**                                                                         |
|-----------------------------------------|-----------------------------------------------------------------------------------------|
| `section(atIndex idx: Int)`             | Return setion at specified index.                                                       |
| `section(forID identifier: String)`     | Return the first section with given identifier inside the table                         |
| `sections(forIDs ids: [String])`        | Return all sections with given identifiers                                              |
| `hasSection(withID identifier: String)` | Return `true` if table contains passed section with given identifier, `false` otherwise |

#### Properties

| **Signature** | **Description**                                                               |
|---------------|-------------------------------------------------------------------------------|
| `isEmpty`     | Return `true` if table does not contains sections or rows                     |
| `sections`    | Return the list of `Sections` actually contained into the manager (read-only) |

<a name="api_sections" />

### `Section`

**Initialize**
* `init(id: String?, row: RowProtocol)` Initialize a new section with a single passed row
* `init(id: String?, _ rows: [RowProtocol]?, header: String?, footer: String?)` Initialize a new section with a list of rows and optionally a standard header and/or footer string.
* `init(id: String?, _ rows: [RowProtocol]?, headerView: SectionProtocol?, footerView: SectionProtocol?)` Initialize a new section with a list of rows and optionally an header/footer as a custom UITableViewHeaderFooterView subclass.

**Reload Section**
* `reload(_ anim: UITableViewRowAnimation?)` Reload current section with given animation (`nil` uses `automatic`)
* `reload(rowsAtIndexes indexes: [IndexPath], animation: UITableViewRowAnimation?)` Reload rows at specified indexes with given animation (`nil` uses `automatic`)
* `reload(rowWithID id: String, animation: UITableViewRowAnimation?)` Reload row with given identifier using passed animation type (`nil` uses `automatic`)
* `reload(rowsWithIDs ids: [String], animation: UITableViewRowAnimation?)` Reload rows with given identifiers using passed animation type (`nil` uses `automatic`)

**Get Rows from Section**
* `rows(withIDs ids: [String]) -> [RowProtocol]` Get rows with given identifiers
* `row(withID id: String?) -> RowProtocol?` Get the first row with given identifier
* `index(ofRowWithID identifier: String?) -> Int?` Return the index of the first row with given identifier
* `indexes(ofRowsWithIDs identifiers: [String]) -> IndexSet?` Return the indexes of rows with given identifiers

**Add/Replace Rows in Section**
* `add(_ row: RowProtocol, at index: Int? = nil)` add a new row into the section optionally specifying the index.
* `add(_ rows: [RowProtocol], at index: Int? = nil)` add rows into the section optionally specifying the index of the first item.
* `replace(rowAt index: Int, with row: RowProtocol)` replace a row with another row.

**Remove Rows from Section**
* `remove(rowAt index: Int)` remove a row at specified index.
* `remove(rowWithID identifier: String?) -> RowProtocol?` remove first row with given identifier
* `remove(rowsWithIDs identifiers: [String]) -> [RowProtocol]` Remove rows with given identifiers

**Other functions**
* `clearAll()` remove all rows of the section

Note: you must call `reloadData()` to reflect changes (or `update()` and add operations inside a block to perform animated reload).

<a name="api_row" />

### `Row`

**Initialize**
* `init(_ item: Cell.T, _ configurator: TableRowConfigurator? = nil)` Initialize a new `Row` with a single model (`item`) and optional configuration block you can define to initialize your class.
* `static func create(_ items: [Cell.T], _ configurator: TableRowConfigurator? = nil)` create a new set of `Rows` of the specified type which hold data for passed models (`items`).

**Manage Heights of the Cell**

* If your cell has a fixed height you can override the static var `defaultHeight` and provide the height (you can also return `UITableViewAutomaticDimension` for autosizing cell).
If your cell supports autosizing you can also override static var `estimatedHeight` to provide an estimate height of the cell.
* If you want to customize the height per instance you need to provide a a valid result to `evaluateRowHeight()` function (and optionally `evaluateEstimatedHeight()`).

**Configure cell with model instance**

Configuration of the cell with an instance of your model is done by declaring `func configure(_ cell: UITableViewCell, path: IndexPath)` in your `UITableViewCell` subclass.
Here you will receive the instance of the cell and relative path (you can use `self.item` to get represented item istance of the row).

You can also observe the `onDequeue` event; it happends just after the cell is dequeued from the table's pool.

<a name="row_events" />

**Observable Events**

The following events are observable by the `Row` instance and allows you to customize behaviour and appearance of the single cell.

* `onDequeue: RowProtocol.RowEventCallback` Message received when a cell instance has been dequeued from table.
* `onTap: ((RowProtocol.RowInfo) -> (RowTapBehaviour?))?` Message received when user tap on a cell at specified path. You must provide a default behaviour by returning one of the `RowTapBehaviour` options. If `nil` is provided the default behaviour is `deselect` with animation.
* `onDelete: RowProtocol.RowEventCallback?` Message received when a selection has been made. Selection still active only if `onTap` returned `.keepSelection` option.
* `onSelect: RowProtocol.RowEventCallback` Message received when a selection has been made. Selection still active only if`onTap` returned `.keepSelection` option.
* `onEdit: ((RowProtocol.RowInfo) -> ([UITableViewRowAction]?))?` Message received when a cell at specified path is about to be swiped in order to allow on or more actions into the context. You must provide an array of UITableViewRowAction objects representing the actions for the row. Each action you provide is used to create a button that the user can tap. By default no swipe actions are returned.
* `onDeselect: RowProtocol.RowEventCallback?` Message received when cell at specified path did deselected.
* `onWillDisplay: RowProtocol.RowEventCallback?` Message received when a cell at specified path is about to be displayed. Gives the delegate the opportunity to modify the specified cell at the given row and column location before the browser displays it.
* `onDidEndDisplay: RowEventCallback?` The cell was removed from the table.
* `onWillSelect: ((RowProtocol.RowInfo) -> (IndexPath?))?` Message received when a cell at specified path is about to be selected.
* `onShouldHighlight: ((RowProtocol.RowInfo) -> (Bool))?` Message received when a cell at specified path is about to be selected. If `false` is returned highlight of the cell will be disabled. If not implemented the default behaviour of the table is to allow highlights of the cell.
* `canMove: ((RowProtocol.RowInfo) -> (Bool))?` Asks the data source whether a given row can be moved to another location in the table view. If not implemented `false` is assumed instead.
* `shouldIndentOnEditing: ((RowProtocol.RowInfo) -> (Bool))?` Asks the delegate whether the background of the specified row should be indented while the table view is in editing mode. If not implemented `true` is returned.

* * *

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
