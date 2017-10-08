## Flow APIs Documentation

* [`TableManager` object](#api_tablemanager)
* [`Section` object](#api_section)
* [`Row` object](#api_row)

* * *

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


- - -

<a name="api_sections" />

### `Section`

#### Initialize

| **Signature**                                                                                           | **Description**                                                                                                                |
|---------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| `init(id: String?, row: RowProtocol)`                                                                   | Initialize a new section with a single passed row                                                                              |
| `init(id: String?, _ rows: [RowProtocol]?, header: String?, footer: String?)`                           | Initialize a new section with a list of rows and optionally a standard header and/or footer string.                            |
| `init(id: String?, _ rows: [RowProtocol]?, headerView: SectionProtocol?, footerView: SectionProtocol?)` | Initialize a new section with a list of rows and optionally an header/footer as a custom UITableViewHeaderFooterView subclass. |


#### Reload Section

| **Signature**                                                                     | **Description**                                                                         |
|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| `reload(_ anim: UITableViewRowAnimation?)`                                        | Reload current section with given animation (`nil` uses `automatic`)                    |
| `reload(rowsAtIndexes indexes: [IndexPath], animation: UITableViewRowAnimation?)` | Reload rows at specified indexes with given animation (`nil` uses `automatic`)          |
| `reload(rowWithID id: String, animation: UITableViewRowAnimation?)`               | Reload row with given identifier using passed animation type (`nil` uses `automatic`)   |
| `reload(rowsWithIDs ids: [String], animation: UITableViewRowAnimation?)`          | Reload rows with given identifiers using passed animation type (`nil` uses `automatic`) |

#### Get Rows from Section

| **Signature**                                               | **Description**                                         |
|-------------------------------------------------------------|---------------------------------------------------------|
| `rows(withIDs ids: [String]) -> [RowProtocol]`              | Get rows with given identifiers                         |
| `row(withID id: String?) -> RowProtocol?`                   | Get the first row with given identifier                 |
| `index(ofRowWithID identifier: String?) -> Int?`            | Return the index of the first row with given identifier |
| `indexes(ofRowsWithIDs identifiers: [String]) -> IndexSet?` | Return the indexes of rows with given identifiers       |

#### Add/Replace Rows in Section

| **Signature**                                      | **Description**                                                              |
|----------------------------------------------------|------------------------------------------------------------------------------|
| `add(_ row: RowProtocol, at index: Int? = nil)`    | Add a new row into the section optionally specifying the index.              |
| `add(_ rows: [RowProtocol], at index: Int? = nil)` | Add rows into the section optionally specifying the index of the first item. |
| `replace(rowAt index: Int, with row: RowProtocol)` | Replace a row with another row.                                              |

#### Remove Rows from Section

| **Signature**                                                | **Description**                        |
|--------------------------------------------------------------|----------------------------------------|
| `remove(rowAt index: Int)`                                   | Remove a row at specified index.       |
| `remove(rowWithID identifier: String?) -> RowProtocol?`      | Remove first row with given identifier |
| `remove(rowsWithIDs identifiers: [String]) -> [RowProtocol]` | Remove rows with given identifiers     |

#### Other functions

| **Signature** | **Description**                |
|---------------|--------------------------------|
| `clearAll()`  | Remove all rows of the section |

Note: you must call `reloadData()` to reflect changes (or `update()` and add operations inside a block to perform animated reload).

- - -


<a name="api_row" />

### `Row`

#### Initialize

| **Signature**                                                                        | **Description**                                                                                                               |
|--------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `init(_ item: Cell.T, _ configurator: TableRowConfigurator? = nil)`                  | Initialize a new `Row` with a single model (`item`) and optional configuration block you can define to initialize your class. |
| `static func create(_ items: [Cell.T], _ configurator: TableRowConfigurator? = nil)` | Create a new set of `Rows` of the specified type which hold data for passed models (`items`).                                 |


#### Manage Heights of the Cell

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
