## Flow
#### The great way to deal with UITableViews in iOS

### What's Flow?
Flow is a Swift lightweight library which help you to better manage content in UITableViews. It's easy and fast, perfectly fits the type-safe nature of Swift.

Say goodbye to the mess of `UITableViewDataSource` and `UITableViewDelegate` implementations: start flowing your tables!

### A real example
This is the code required to create a table with some football players (belive me, it's inside the project example):

```swift
let players = PlayerModel.load("RealMadrid") // load models
let rows = Row<PlayerCell>.create(players, { row in // create rows
row.onTap = { _,path in // reponds to tap
 print("Tap on '\(row.item.fullName)'")
 return nil
}
self.tableManager?.add(rows: rows)
```

**Feel amazing uh? Yeah it is**, and there's more: handle tap events, customize editing, easy create footer and headers...

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
* iOS8+
* Swift 3+

We are supporting both [CocoaPods]() and [Chartage]().

### Index
* [What's Flow?]()
* [Main Features]()