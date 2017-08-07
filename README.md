## Flow
#### The great way to deal with UITableViews in iOS

### What's Flow?
Flow is a Swift lightweight library which help you to better manage content in UITableViews. It's easy and fast, perfectly fits the type-safe nature of Swift.

Say goodbye to the mess of `UITableViewDataSource` and `UITableViewDelegate` implementations: start flowing your tables!

### What it can do
The following code is the only required to create a table for some football players *(you can also find it in our example application)*:

```swift
let players: [PlayerModel] = ... // load player's models
let rows = Row<PlayerCell>.create(players, { row in // create rows
row.onTap = { _, path in // reponds to tap
 print("Tap on '\(row.item.fullName)'")
 return nil
}
tableManager.add(rows: rows)
```

A complete table in few lines of code; **feel amazing uh? Yeah it is**, and there's more: handle tap events, customize editing, easy create footer and headers...

### Main Features
Main features of Flow includes:
* **Declare the content**: Decide cell's class, the model and use array-like methods to add/remove or manage rows into the table. No more data source, no more delegate, just plain understandable methods to manage what kind of data you want to display (auto animations included!).
* **Separation of concerns**: Let the cell do its damn job; passing represented item (model) to the cell you can add a layer of separation between your model, your view controller and the cell which represent the model itself. Stop doing cell population inside the `tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)` datasource function. Be [SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)).
* **Type-safe**: Describe your cell classes, the model to represent and let the library take care of you. Allocation and configuration is automatic: no more reuse identifier strings, no more dequeue operations, no more casts.
* **FP (Functional Programming) Style**. Cell configurations is easy; you can observe events and manage the behaviour of the cells in a functional style.
* **AutoLayout support**: Provide a simple mechanism to specify the height of a cell or leave the class decide the best one upon described constraints.
* **Animations**: Like `performBatchUpdates` of `UICollectionView` Flow manage automatically what kind of animations perform on the table as you change the layout.

### Requirements
Flow minimum requirements are:
* iOS 8+
* Swift 3+

We are supporting both [CocoaPods]() and [Chartage]().

### Author & License
Flow was created and mantained by [Daniele Margutti](http://www.danielemargutti.com); you can contact me at [hello@danielemargutti.com](mailto://hello@danielemargutti.com) or on twitter at [@danielemargutti](http://www.twitter.com/danielemargutti).

This library is licensed under [MIT License](https://opensource.org/licenses/MIT).

If you are using it in your software:
* Add a notice in your credits/copyright box: `Flow for UITableViews - © 2017 Daniele Margutti - www.danielemargutti.com`
* *(optional but appreciated)* [Click here to report me](https://github.com/malcommac/flow/issues/new?labels[]=Share&labels[]=[Type]%20Share&title=I'm%20using%20your%20library%20in%20my%20software&body=Hi,%20I'm%20using%20your%20library%20in%20my%20software;%20you%20can%20found%20it%20at%20the%20following%20link:) **your app using Flow**.

### Full documentation
* [Basic Entities]()
* [A small example]()
  * [Create the `TableManager`]()
  * [Create `UITableViewCell` subclass]()
  * [Create Cells in Interface Builder]()
  * [Manage the size of the `UITableViewCell`]()
  * [Create your `Rows`]()
  * [Create a new `Section` (and manage Header and Footer)]()
* [Respond to `Row` events]()
* [Supporting `UITableView` Animations]()


#### Basic Entities
Flow basically is composed by four different entities:
* **TableManager**: a single table manager is responsible to manage the content of a `UITableView` instance.
* **Section**: represent a section of a table. It encapsulate the logic to manage rows into the section, custom header or footer.
* **Row**: represent a single row of the table; when you create a new row to insert into the table you will specify the class you want to use to represent it (a subclass of `UITableViewCell`) and the model which you are about to represent (any object you want).
* **SectionView**: if you want to create custom header/footer into the table you are using this class to create reusable views. As like for rows also `SectionView` are associated to a specific model to represent.

#### Create the `TableManager`

First of all you need to create your table manager.
You will create it (generally) in your view controller:

```swift
self.tableManager = TableManager(table: self.table!)
```

From now your `UITableView` instance is backed by Flow Table Manager; you will refer to it to manage the content you want to display.

#### Create `UITableViewCell` subclass

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
#### Create Cells in Interface Builder

You can create the UI of your cell in two different ways:
* **Using Storyboard**: create a new prototype cell, assign the class to your class (here `PlayerCell`) and set the `reuseIdentifier` in IB to the same name of the class (again `PlayerCell`). By default Flow uses as identifier of the cell the same name of the class itself (you can change it by overriding `reuseIdentifier` static property).
* **Manually**: create a new xib file with the same name of your cell class (here `PlayerCell.xib`) and drag an instance of `UITableViewCell` class as the only single top level object. Assign to it the name of your class and the `reuseIdentifier`.

Flow will take care of the load and dequeue of the instances for you!

#### Manage the size of the `UITableViewCell`

If your cell has a fixed height which does not change with the content of the model you want also implement the following static properties:

* `defaultHeight` (`CGFLoat`): return the height of the cell (if your cell is autosizing you can also return `UITableViewAutomaticDimension`)
* `estimatedHeight` (`CGFloat`): return estimated height (only for autosizing cells)

If your cell needs to evaluate the height based upon the content you can override the `evaluateRowHeight()` and/or `evaluateEstimatedHeight()` of your `Row` class (we'll see it later).

#### Create your `Rows`

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

#### Create a new `Section` (and manage Header and Footer)
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

#### Supporting TableView Animations

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

#### Respond to `Row` events

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

All other events are described in [Row Events]() section.

#### `TableManager` functions

**Reload**
* `reloadData()` reload the data inside managed table. You must call it at the end of your operation in order to reflect changes. Reload is not animated.
* `update(animation:block:)` allows to perform a batch of operations on table's sections and rows. At the end of the block animations are collected and executed to reflect into the UI changes applied to the model.

Note: all of these events can be used sequentially but you need to call `reloadData()` at the end. To perform animated editing use `update()` function instead (but take care of the order of your operations).

**Add sections**
* `add(section: Section)` add a new section at the end of the table
* `add(sectionsToAdd: [Section])` add new set of sections at the end of the table

**Add rows**
* `add(row: RowProtocol, in section: Section? = nil)` add row at the end of specified section. If `section` is null a new section is created with the row.
* `add(row: RowProtocol, inSectionAt index: Int? = nil)` add row at specified section index. If `section` is `nil` a new section is created with the `row` and append at the end of the table.
* `add(rows: [RowProtocol], in section: Section? = nil)` add rows into a section. If `section` is not specified a new section is created automatically with passed `rows`.
* `add(rows: [RowProtocol], inSectionAt index: Int? = nil)` add `rows` in section at `index` (if valid). If `section` is `nil` a new section is created automatically with passed `rows`.

**Move/Insert/Replace rows**
* `move(row indexPath: IndexPath, to destIndexPath: IndexPath)` move a row in another position. This is a composed operation: first of all row is removed from source, then is added to the new path.
* `insert(section: Section, at index: Int)` Insert a section at specified index of the table.
* `replace(sectionAt index: Int, with section: Section)` Replace an existing section with the new passed.
* `remove(sectionAt index: Int)` Remove an existing section at specified index.
* `removeAll()` remove all the sections of the table.

**Get section**
* `section(atIndex idx: Int)` return setion at specified index.

#### `Section` functions

**Initialize**
* `init(_ rows:, header:,footer:)` Initialize a new section with a set of `rows`, optional simple header/footer strings.
* `init(_ rows:,headerView:,footerView:` Initialzie a new section with a set of `rows`, optional custom view for header and/or footer. Header and footer must be `UITableViewHeaderFooterView` subclasses which responds to `SectionProtocol` protocol.

**Other functions**

Note: you must call `reloadData()` to reflect changes (or `update()` and add operations inside a block to perform animated reload).

* `clearAll()` remove all rows of the section
* `add(_ row: RowProtocol, at index: Int? = nil)` add a new row into the section optionally specifying the index.
* `add(_ rows: [RowProtocol], at index: Int? = nil)` add rows into the section optionally specifying the index of the first item.
* `replace(rowAt index: Int, with row: RowProtocol)` replace a row with another row.
* `remove(rowAt index: Int)` remove a row at specified index.

#### `Row` functions

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
