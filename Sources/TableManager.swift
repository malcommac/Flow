//
//	Flow
//	A declarative approach to UITableView management
//	------------------------------------------------
//	Created by:	Daniele Margutti
//				hello@danielemargutti.com
//				http://www.danielemargutti.com
//
//	Twitter:	@danielemargutti
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation
import UIKit

/// TableManager is the class which manage the content and events of a `UITableView`.
/// You need to allocate this class with a valid table instance to manage.
/// Then you can use public funcs to add, remove or move rows.
open class TableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
	
	/// Scroll view delegate for associated table
	public weak var scrollViewDelegate: UIScrollViewDelegate? = nil
	
	/// This represent which table should be managed by this instance
	private(set) weak var tableView: UITableView?
	
	/// This array contains all the removed row in an update sessions.
	/// It's used to dispatch `onDidEndDisplay` messages before a cell is definitively removed
	/// from table.
	internal var removedRows: [Int: RowProtocol] = [:]
	
	internal func keepRemovedRows(_ rows: [RowProtocol]) {
		rows.forEach {
			if let cell = $0._instance {
				removedRows[cell.hashValue] = $0
			}
		}
	}
	
	/// Number of sections in table
	private(set) var sections: ObservableArray<Section> = [] { // [Section] = [] {
		didSet {
			let (indexes, titles) = self.regenerateSectionIndexes()
			self.sectionsIndexes = indexes
			self.sectionsIndexesTitles = titles
		}
	}
	
	/// The row animation that will be displayed when sections are inserted or removed.
	/// You can change it just before doing changes to the model
	public var sectionAnimation: UITableViewRowAnimation = .automatic
	
	/// Registered `UITableViewCell` identifiers
	private var registeredCellIDs: Set<String> = []
	
	/// Registered `UITableHeaderFooterView` identifiers
	private var registeredViewsIDs: Set<String> = []

	/// Indexes of the table
	private var sectionsIndexes: [Int]? = nil
	
	/// Indexes's titles of the table
	private var sectionsIndexesTitles: [String]? = nil
	
	/// Cached heights
	private var cachedRowHeights: [Int: CGFloat] = [:]
	
	/// Cell prototypes's cache
	private var prototypesCells: [String: UITableViewCell] = [:]
	
	/// If `true` the manager attempt to evaluate the size of the row automatically.
	/// The process maybe expensive (but cached); you should use it only if needed. If you can
	/// provide the height of a row easily you should do it.
	/// The process attempt to initialize a new instance of required cell, then layout subviews
	/// and uses `systemLayoutSizeFitting()` on cell's `contentView` to calculate the size.
	/// If zero value is returned it uses the cell's `contentView` bounds.
	private var estimateRowSizeAutomatically: Bool = true
	
	/// Initialize a new manager for a specific `UITableView` instance
	///
	/// - Parameter table: table instance to manage
	public init(table: UITableView, estimateRowHeight: Bool = true) {
		super.init()
		self.estimateRowSizeAutomatically = estimateRowHeight
		self.tableView = table
		self.tableView?.delegate = self
		self.tableView?.dataSource = self
	}
	
	/// Perform a non-animated reload of the data
	/// If you don't use `update` func you should call it when an operation on
	/// sections or rows in section in order to reflect changes on UI.
	public func reloadData() {
		self.clearHeightCache()
		self.tableView?.reloadData()
	}
	
	/// Perform an update session on the table. You are able to use all funcs to manipulate sections and rows in sections.
	/// You must however pay attention to the order of the operations you want to perform.
	///
	/// Deletes are processed before inserts in batch operations.
	/// This means the indexes for the deletions are processed relative to the indexes of the collection view’s state
	/// before the batch operation, and the indexes for the insertions are processed relative to the indexes of the
	/// state after all the deletions in the batch operation.
	///
	/// Morehover, in order to make a correct refresh of the data, insertion must be done in order of the row index.
	///
	/// - Parameters:
	///   - animation: animation to perform; if `nil` no animation is performed and a simple `reloadData()` is done instead.
	///   - block: block with the operation to perform.
	public func update(animation: UITableViewRowAnimation? = nil,
	                   _ block: @escaping (() -> (Void))) {
		guard let animation = animation else {
			block()
			self.tableView?.reloadData()
			return
		}
		
		// Generate a session id for this operation
		// we will register an observer for the table's sections changes
		// and one for every section to observe changes inside the rows.
		// All these observer are the same session ID; data will be grouped to perform
		// animations.
		let sessionUUID = self.generateSessionObservers()
		// Allow user to execute operations
		block()
		// Perform animations
		self.tableView?.beginUpdates()
		// Execute operations on table's data source
		self.commit(updatesForSession: sessionUUID, using: animation)
		self.tableView?.endUpdates()
	}
	

	/// This function generate operations to manipulate table using batch of animations
	///
	/// - Returns: session observer
	private func generateSessionObservers() -> String {
		let observerUUID = NSUUID().uuidString

		self.sections.observe(ArrayObserver(observerUUID)) // observe section changes
		// observe changes in any section
		self.sections.forEach {
			let observerOfSection = ArrayObserver(observerUUID)
			$0.rows.observe(observerOfSection)
		}
		
		return observerUUID
	}
	
	private func commit(updatesForSession UUID: String, using animation: UITableViewRowAnimation) {
		self.commit(sectionUpdates: self.sections.observers[UUID]?.events, using: animation)
		
		self.sections.enumerated().forEach { (idx,section) in
			self.commit(rowUpdates: section.rows.observers[UUID]?.events, section: idx, using: animation)
		}
	}
	
	
	/// Commit actions to manipulate table's section
	///
	/// - Parameters:
	///   - updates: updates
	///   - animation: animation to perform
	private func commit(sectionUpdates updates: [Event]?, using animation: UITableViewRowAnimation) {
		guard let updates = updates else { return }
		updates.forEach {
			switch $0.type {
			case .deleted:
				self.tableView?.deleteSections(IndexSet($0.indexes), with: animation)
			case .inserted:
				self.tableView?.insertSections(IndexSet($0.indexes), with: animation)
			case .updated:
				self.tableView?.reloadSections(IndexSet($0.indexes), with: animation)
			}
		}
	}
	
	
	/// Commit actions to manipulate table's rows
	///
	/// - Parameters:
	///   - updates: updates
	///   - section: parent section
	///   - animation: animation
	private func commit(rowUpdates updates: [Event]?, section: Int, using animation: UITableViewRowAnimation) {
		guard let updates = updates else { return }
		updates.forEach {
			switch $0.type {
			case .deleted:
				let paths: [IndexPath] = $0.indexes.map {
					print("delete row=\($0) (section=\(section)")
					return IndexPath(row: $0, section: section)
				}
				self.tableView?.deleteRows(at: paths, with: animation)
			case .inserted:
				let paths: [IndexPath] = $0.indexes.map {
					print("insert row=\($0) (section=\(section)")
					return IndexPath(row: $0, section: section)
				}
				self.tableView?.insertRows(at: paths, with: animation)
			case .updated:
				let paths = $0.indexes.map { IndexPath(row: $0, section: section) }
				self.tableView?.reloadRows(at: paths, with: animation)
			}
		}
	}
	
	/// Return the first section with given identifier inside the table
	///
	/// - Parameter identifier: identifier to search
	/// - Returns: found Section or `nil`
	public func section(forID identifier: String) -> Section? {
		return self.sections.first(where: { $0.identifier == identifier })
	}
	
	/// Return the first row with given identifier inside all sections of the table
	///
	/// - Parameter identifier: identifier to search
	/// - Returns: found Row, or `nil`
	public func row(forID identifier: String) -> RowProtocol? {
		for section in self.sections {
			if let firstMatch = section.rows.first(where: { $0.identifier == identifier }) {
				return firstMatch
			}
		}
		return nil
	}
	
	/// Return any row in table's section with given identifiers
	///
	/// - Parameter identifiers: identifiers to search
	/// - Returns: found `[Row]` or empty array
	public func row(forIDs identifiers: [String]) -> [RowProtocol] {
		var list: [RowProtocol] = []
		for section in self.sections {
			list.append(contentsOf: section.rows.filter {
				if let id = $0.identifier {
					return identifiers.contains(id)
				}
				return false
			})
		}
		return list
	}
	
	/// Add a new section to the table
	///
	/// - Parameter section: section to add
	/// - Returns: self
	@discardableResult
	public func add(section: Section) -> Self {
		self.sections.append(section)
		return self
	}

	
	/// Add a list of sections to the table
	///
	/// - Parameter sectionsToAdd: sections to add
	/// - Returns: self
	@discardableResult
	public func add(sectionsToAdd: [Section]) -> Self {
		self.sections.append(contentsOf: sectionsToAdd)
		return self
	}
	
	/// Add rows to a section, if section is `nil` a new section is appened with rows at the end of table
	///
	/// - Parameters:
	///   - rows: rows to add
	///   - section: destination section, `nil` create and added a new section at the end of the table
	/// - Returns: self
	@discardableResult
	public func add(rows: [RowProtocol], in section: Section? = nil) -> Self {
		if let section = section {
			section.rows.append(contentsOf: rows)
		} else {
			let newSection = Section(rows: rows)
			newSection.manager = self
			self.sections.append(newSection)
		}
		return self
	}
	
	/// Add rows to a section specified at index
	///
	/// - Parameters:
	///   - rows: rows to add
	///   - index: index of the destination section.
	/// - Returns: self
	@discardableResult
	public func add(rows: [RowProtocol], inSectionAt index: Int) -> Self {
		guard index < self.sections.count else { return self }
		self.sections[index].rows.append(contentsOf: rows)
		return self
	}

	/// Add a new row into a section; if section is `nil` a new section is created and added at the end
	/// of table.
	///
	/// - Parameters:
	///   - row: row to add
	///   - section: destination section, `nil` create and added a new section at the end of the table
	/// - Returns: self
	@discardableResult
	public func add(row: RowProtocol, in section: Section? = nil) -> Self {
		if let section = section {
			section.rows.append(row)
		} else {
			let newSection = Section(rows: [row])
			newSection.manager = self
			self.sections.append(newSection)
		}
		return self
	}
	
	
	/// Add a new row into specified section.
	///
	/// - Parameters:
	///   - row: row to add
	///   - index: index of the destination section.
	/// - Returns: self
	@discardableResult
	public func add(row: RowProtocol, inSectionAt index: Int) -> Self {
		guard index < self.sections.count else { return self }
		self.sections[index].rows.append(row)
		return self
	}
	
	/// Move a row in another position.
	/// This is a composed operation: first of all row is removed from source, then is added to the new path.
	///
	/// - Parameters:
	///   - indexPath: source index path
	///   - destIndexPath: destination index path
	public func move(row indexPath: IndexPath, to destIndexPath: IndexPath) {
		let row = self.section(atIndex: indexPath.section)!.remove(rowAt: indexPath.row)
		self.section(atIndex: destIndexPath.section)!.add(row, at: destIndexPath.row)
	}
	
	/// Insert a section at specified index of the table
	///
	/// - Parameters:
	///   - section: section
	///   - index: index where the new section must be inserted
	/// - Returns: self
	@discardableResult
	public func insert(section: Section, at index: Int) -> Self {
		self.sections.insert(section, at: index)
		return self
	}
	
	/// Replace an existing section with the new passed
	///
	/// - Parameters:
	///   - index: index of section to replace
	///   - section: new section to use
	/// - Returns: self
	@discardableResult
	public func replace(sectionAt index: Int, with section: Section) -> Self {
		guard index < self.sections.count else { return self }
		self.keepRemovedRows(Array(self.sections[index].rows))
		self.sections[index] = section
		return self
	}
	
	/// Remove an existing section at specified index
	///
	/// - Parameter index: index of the section to remove
	/// - Returns: self
	@discardableResult
	public func remove(sectionAt index: Int) -> Self {
		guard index < self.sections.count else { return self }
		self.keepRemovedRows(Array(self.sections[index].rows))
		self.sections.remove(at: index)
		return self
	}
	
	/// Remove all sections from the table
	///
	/// - Returns: self
	@discardableResult
	public func removeAll() -> Self {
		let removedRows = self.sections.flatMap { $0.rows }
		self.keepRemovedRows(removedRows)
		self.sections.removeAll()
		return self
	}
	
	/// Get section at given index
	///
	/// - Parameter idx: index of the section
	/// - Returns: section, `nil` if index is invalid
	public func section(atIndex idx: Int) -> Section? {
		guard idx < self.sections.count else { return nil }
		return self.sections[idx]
	}
	
	
	//MARK: -- TableView Data Source Managment
	
	/// Number of section in table
	///
	/// - Parameter tableView: target table
	/// - Returns: number of sections
	public func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count
	}
	
	/// Number of rows in a particular section of the table
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section to get the number of elements
	/// - Returns: number of rows for this section
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.sections[section]).countRows
	}
	
	/// Tells the delegate that the specified cell was removed from the table.
	///
	/// - Parameters:
	///   - tableView: target table
	///   - cell: cell instance
	///   - indexPath: index path of the cell
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let hashedRow = cell.hashValue
		guard let row = self.removedRows[hashedRow] else {
			return
		}
        let cell = tableView.cellForRow(at: indexPath) // instance of the cell
        row.onDidEndDisplay?((cell,indexPath))
		self.removedRows.removeValue(forKey: hashedRow)
    }
	
	/// Cell for a particular `indexPath` in target table
	///
	/// - Parameters:
	///   - tableView: target table
	///   - indexPath: index path for the cell
	/// - Returns: a dequeued cell
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Identify the row to allocate, register if necessary
		let row = self.sections[indexPath.section].rows[indexPath.row]
		self.register(row: row)
		
		// Allocate the class
		let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
		self.adjustLayout(forCell: cell) // adjust width of the cell if necessary
		
		// configure the cell
		row.configure(cell, path: indexPath)
		
		// dispatch dequeue event
		row.onDequeue?((cell,indexPath))
		
		return cell
	}
	
	
	/// Asks the delegate for the estimated height of a row in a specified location.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path that locates a row in tableView.
	/// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be.
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = self.sections[indexPath.section].rows[indexPath.row]
		let height = self.rowHeight(forRow: row, at: indexPath)
		return height
	}
	
	
	/// Asks the delegate for the estimated height of a row in a specified location.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path that locates a row in tableView.
	/// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        return self.rowHeight(forRow: row, at: indexPath, estimate: true)
    }
	
	/// Tells the delegate that a header view is about to be displayed for the specified section.
	///
	/// - Parameters:
	///   - tableView: target tableview
	///   - view: view of the header
	///   - section: section
	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let sectionView = self.sections[section].headerView else {
			return
		}
		sectionView.onWillDisplay?((view as? UITableViewHeaderFooterView,.header,section))
	}
	
	/// Tells the delegate that the specified header view was removed from the table.
	///
	/// - Parameters:
	///   - tableView: target tableview
	///   - view: view of the header
	///   - section: section
	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		guard let sectionView = self.sections[section].headerView else {
			return
		}
		sectionView.didEndDisplaying?((view as? UITableViewHeaderFooterView,.header,section))
	}
	
	///MARK: Footer
	
	
	/// Simple header string
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: header string if present, `nil` otherwise
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return (self.sections[section]).headerTitle
	}
	
	/// Custom view to represent the header of a section
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: header view to use (it overrides header string if set)
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return self.registerAndDequeueSection(at: section, .header)
	}
	
	/// Asks the delegate for the estimated height of the header of a particular section.
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the estimated height of the header instance
	public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return self.sectionHeight(at: section, estimated: false, .header)
	}
	
	/// Height of the header for a section. It will be used only for header's custom view
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the height of the header
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.sectionHeight(at: section, estimated: false, .header)
	}
	
	///MARK: Footer
	
	/// Simple footer string
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: footer string if present, `nil` otherwise
	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return (self.sections[section]).footerTitle
	}
	
	/// Custom view to represent the footer of a section
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: footer view to use (it overrides footer string if set)
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return self.registerAndDequeueSection(at: section, .footer)
	}
	
	/// Height of the footer for a section. It will be used only for footer's custom view
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the height of the footer instance
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return self.sectionHeight(at: section, estimated: false, .footer)
	}
	
	/// Asks the delegate for the estimated height of the footer of a particular section.
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the estimated height of the footer instance
	public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		return self.sectionHeight(at: section, estimated: true, .footer)
	}
	
	/// Tells the delegate that a footer view is about to be displayed for the specified section.
	///
	/// - Parameters:
	///   - tableView: target tableview
	///   - view: view of the header
	///   - section: section
	public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		guard let sectionView = self.sections[section].footerView else {
			return
		}
		sectionView.onWillDisplay?((view as? UITableViewHeaderFooterView,.footer,section))
	}
	
	/// Tells the delegate that the specified footer view was removed from the table.
	///
	/// - Parameters:
	///   - tableView: target tableview
	///   - view: view of the footer
	///   - section: section
	public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		guard let sectionView = self.sections[section].headerView else {
			return
		}
		sectionView.didEndDisplaying?((view as? UITableViewHeaderFooterView,.footer,section))
	}
	
	/// Support to show right side index like in the address book
	///
	/// - Parameter tableView: target table
	/// - Returns: strings to show for each section of the table
	public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.sectionsIndexesTitles
	}
	
	/// Asks the data source to return the index of the section having the given
	/// title and section title index.
	///
	/// - Parameters:
	///   - tableView: tableview
	///   - title:	The title as displayed in the section index of tableView.
	///   - index:	An index number identifying a section title in the array returned
	///				by `sectionIndexTitles(for:)`.
	/// - Returns: An index number identifying a section.
	public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return (self.sectionsIndexes?[index] ?? 0)
	}
	
	
	/// Tells the delegate that a specified row is about to be selected.
	///
	/// - Parameters:
	///   - tableView: A table-view object informing the delegate about the impending selection.
	///   - indexPath: An index path locating the row in tableView.
	/// - Returns:	An index-path object that confirms or alters the selected row.
	///				Return an NSIndexPath object other than indexPath if you want another cell
	///				to be selected. Return nil if you don't want the row selected.
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let cell = tableView.cellForRow(at: indexPath) // instance of the cell
		let row = self.sections[indexPath.section].rows[indexPath.row]

		if let onWillSelect = row.onWillSelect {
			return onWillSelect((cell,indexPath))
		} else {
			return indexPath // not implemented
		}
	}
	
	/// Called to let you know that the user selected a row in the table.
	///
	/// - Parameters:
	///   - tableView: target table
	///   - indexPath: An index path locating the new selected row in tableView.
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) // instance of the cell
		let row = self.sections[indexPath.section].rows[indexPath.row]
		
		let select_behaviour = row.onTap?((cell,indexPath)) ?? .deselect(true)
		switch select_behaviour {
		case .deselect(let animated):
			// remove selection, is a temporary tap selection
			tableView.deselectRow(at: indexPath, animated: animated)
		case .keepSelection:
			row.onSelect?((cell,indexPath)) // dispatch selection change event
		}
	}
	
	/// Tells the delegate that the specified row is now deselected.
	///
	/// - Parameters:
	///   - tableView: target table
	///   - indexPath: An index path locating the deselected row in tableView.
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		// Dispatch on de-select event to the represented model of the row
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		row.onDeselect?((cell,indexPath))
	}
	
	
	/// Tells the delegate that the table view will display the specified cell at the
	/// specified row and column.
	///
	/// - Parameters:
	///   - tableView: The table view that sent the message.
	///   - cell: The cell to be displayed.
	///   - indexPath: An index path locating the row in tableView
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// Dispatch display event for a particular cell to its represented model
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		row.onWillDisplay?((cell,indexPath))
	}
	
	
	/// Asks the delegate if the specified row should be highlighted
	///
	/// - Parameters:
	///   - tableView: The table-view object that is making this request.
	///   - indexPath: The index path of the row being highlighted.
	/// - Returns: `true` or `false`.
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		return row.onShouldHighlight?((cell,indexPath)) ?? true
	}
	
	
	/// Asks the data source to verify that the given row is editable.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path locating a row in tableView.
	/// - Returns: true if the row indicated by indexPath is editable; otherwise, false.
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		// If no actions are definined cell is not editable
		return row.onEdit?((cell,indexPath))?.count ?? 0 > 0
	}
	
	
	/// Asks the delegate for the actions to display in response to a swipe in the specified row.
	///
	/// - Parameters:
	///   - tableView: The table view object requesting this information.
	///   - indexPath: The index path of the row.
	/// - Returns: An array of UITableViewRowAction objects representing the actions
	///            for the row. Each action you provide is used to create a button that the user can tap.
	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		return row.onEdit?((cell,indexPath)) ?? nil
	}
	
	
	/// Asks the delegate for the editing style of a row at a particular location in a table view.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path locating a row in tableView.
	/// - Returns: The editing style of the cell for the row identified by indexPath.
	open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		row.onDelete?((cell,indexPath))
	}
	
	
	/// Asks the data source whether a given row can be moved to another location in the table view.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path locating a row in tableView.
	/// - Returns: boolean
	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		return row.canMove?((cell,indexPath)) ?? false
	}
	
	/// Asks the delegate whether the background of the specified row should be indented
	/// while the table view is in editing mode.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index-path object locating the row in its section.
	/// - Returns: boolean
	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.sections[indexPath.section].rows[indexPath.row]
		return row.shouldIndentOnEditing?((cell,indexPath)) ?? true
	}
	
	///MARK: Private Helper Methods
	
	/// This function evaluate the height of a section.
	/// Height is evaluated in this order:
	/// -	if the instance provide an implementation of `evaluateViewHeight()`/`evaluateEstimatedHeight` then use it
	///		if return a non `nil` value
	/// -	if the static var `defaultHeight`/`estimatedHeight` of the view's class return a non `nil` value use it
	/// -	return `UITableViewAutomaticDimension`
	///
	/// - Parameters:
	///   - index: section index
	///   - type: type of view (`header` or `footer`)
	/// - Returns: height of the section
	private func sectionHeight(at index: Int, estimated: Bool, _ type: SectionType) -> CGFloat {
		guard let sectionView = self.sections[index].headerView else {
			return UITableViewAutomaticDimension
		}
		
		// Has the user provided an evaluation function for view's height? If yes we can realy to it
		if estimated == false {
			if sectionView.evaluateViewHeight != nil {
				if let height = sectionView.evaluateViewHeight!(type) {
					return height
				}
			}
			
			// Had the user provided a static function which return the height of the view inside the view's class?
			if let static_height = sectionView.defaultHeight {
				return static_height
			}
			
		} else {
			if sectionView.evaluateEstimatedHeight != nil {
				if let height = sectionView.evaluateEstimatedHeight!(type) {
					return height
				}
			}
			
			// Had the user provided a static function which return the height of the view inside the view's class?
			if let static_height = sectionView.estimatedHeight {
				return static_height
			}
		}
		
		
		// If no other function are provided we can return the the automatic dimension
		return UITableViewAutomaticDimension
	}
	
	/// This function is responsibile to register (if necessary) and header/footer section view and return a new instance
	/// for a given section.
	///
	/// - Parameter index: index of the section
	/// - Returns: defined header/footer instance
	private func registerAndDequeueSection(at index: Int, _ type: SectionType) -> UIView? {
		// Was the section's header customized with a view?
		var sectionItem: SectionProtocol? = nil
		if type == .header {	sectionItem = self.sections[index].headerView
		} else {				sectionItem = self.sections[index].footerView }
		
		guard let sectionView = sectionItem else {
			return nil
		}
		
		// Attempt to register header/footer custom view for given reuse identifier, if necessary
		self.register(section: sectionView)
		
		// instantiate custom section
		guard let header = tableView?.dequeueReusableHeaderFooterView(withIdentifier: sectionView.reuseIdentifier) else {
			return nil
		}
		// give a chance to configure the header
		sectionView.configure(header, type: type, section: index)
		
		// call the on dequeue function
		sectionView.onDequeue?((header, type, index))
		
		return header
	}
	
	/// This function regenerate the indexes for each section in table
	///
	/// - Returns: return filled indexes and titles for each section
	private func regenerateSectionIndexes() -> (indexes: [Int]?, titles: [String]?) {
		var titles: [String] = []
		var indexes: [Int] = []
		
		self.sections.enumerated().forEach { idx,section in
			if let title = section.indexTitle {
				indexes.append(idx)
				titles.append(title)
			}
		}
		
		return ((indexes.isEmpty == false ? indexes : nil), titles)
	}
	
	/// Adjust layout of the cell by setting the width to the same with of the table and calling `layoutIfNeeded()`
	///
	/// - Parameter cell: cell instance
	private func adjustLayout(forCell cell: UITableViewCell) {
		guard cell.frame.size.width != self.tableView!.frame.size.width else {
			return
		}
		cell.frame = CGRect(x: 0, y: 0, width: self.tableView!.frame.size.width, height: cell.frame.size.height)
		cell.layoutIfNeeded()
	}
	
	/// This function is used internally to register a class to be used as header/footer into the table.
	/// If the vieew is already registered for its reuseIdentifier nothing is made.
	/// By default the `reuseIdentifier` of a view is the name of the class itself.
	/// View must be declared in a separate xib file (this because it cannot be allocated as like cells
	/// inside the storyboard itself) which has the same name of the class.
	/// Xib file must contain a single top level object which is the UITableHeaderFooterView subclass
	/// we want to use.
	///
	/// - Parameter section: section (header/footer) to register
	private func register(section: SectionProtocol) {
		let reuseIdentifier = section.reuseIdentifier
		guard registeredViewsIDs.contains(reuseIdentifier) == false else {
			return
		}
		
		// View is not registered yet. Attempt to load xib file or register the class itself
		// so it will be available for later dequeue.
		let sectionView: AnyClass = section.viewType
		let sourceBundle = Bundle(for: sectionView)
		if let _ = sourceBundle.path(forResource: reuseIdentifier, ofType: "nib") {
			let xib = UINib(nibName: reuseIdentifier, bundle: sourceBundle)
			tableView?.register(xib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
		} else {
			tableView?.register(sectionView, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
		}
		
		self.registeredViewsIDs.insert(reuseIdentifier)
	}
	
	/// This function is used internally to register a class to be used as cell into the table.
	/// If cell is already registered for its reuseIdentifier nothing is made. By default the
	/// reuseIdentifier of a cell is the name of the class itself.
	/// If cell is not registered and its not part of the table's (in a storyboard) a xib file
	/// with the same name of the cell class is used.
	/// Xib file must contain a single top level object which is the UITableViewCell representation.
	///
	/// - Parameter row: row to register
	private func register(row: RowProtocol) {
		// We have already registered this identifier, so we can skip this routine
		let reuseIdentifier = row.reuseIdentifier
		guard registeredCellIDs.contains(reuseIdentifier) == false else {
			return
		}
		
		// Check if this identifier is already registered by the storyboard itself
		// This is the common strategy when you want to use storyboard instead of xib files.
		guard tableView?.dequeueReusableCell(withIdentifier: reuseIdentifier) == nil else {
			return
		}
		
		// Fallback is to look at a xib file where the single cell is defined.
		// This is a constraint of the TableManager: xib files must have the same name of the cell type
		// otherwise search operation fails.
		//
		// Clearly we are about to search in the same bundle of the class itself.
		let cell: AnyClass = row.cellType
		let sourceBundle = Bundle(for: cell)
		if let _ = sourceBundle.path(forResource: reuseIdentifier, ofType: "nib") {
			let nib = UINib(nibName: reuseIdentifier, bundle: sourceBundle)
			tableView?.register(nib, forCellReuseIdentifier: reuseIdentifier)
		} else {
			tableView?.register(cell, forCellReuseIdentifier: reuseIdentifier)
		}
		
		self.registeredCellIDs.insert(reuseIdentifier)
	}
	
	private func rowHeight(forRow row: RowProtocol, at indexPath: IndexPath, estimate: Bool = false) -> CGFloat {
		let row = self.sections[indexPath.section].rows[indexPath.row]

        /// If a fixed height is provided, we'll use it
        if let fixedHeight = row.rowHeight {
            return fixedHeight
        }
        
		/// User provided a function to evaluate the height of the table
		if row.evaluateRowHeight != nil {
			if let height = row.evaluateRowHeight!() {
				return height
			}
		}
		
		/// User provided the height of the table at class level (static based)
		if let static_height = row._defaultHeight {
			return static_height
		}
		
		/// Attempt to estimate the height of the row automatically
		if self.estimateRowSizeAutomatically == true && estimate == true {
            return self.estimatedHeight(forRow: row, at: indexPath)
		}

		// universal fallback to automatic dimension
		return UITableViewAutomaticDimension
	}
	
	/// This function attempt to evaluate the height of a cell
	///
	/// - Parameters:
	///   - row: the row to evaluate
	///   - indexPath: path of the row
	/// - Returns: the evaluated height
	private func height(forRow row: RowProtocol, at indexPath: IndexPath) -> CGFloat {
		if let height = self.cachedRowHeights[row.hashValue] {
			return height
		}
		
		var prototype_instance = self.prototypesCells[row.reuseIdentifier]
		if prototype_instance == nil {
			prototype_instance = tableView?.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
			self.prototypesCells[row.reuseIdentifier] = prototype_instance
		}
		
		guard let cell = prototype_instance else { return 0 }
		
		cell.prepareForReuse()
		row.configure(cell, path: indexPath)
		cell.bounds = CGRect(x: 0, y: 0, width: tableView!.bounds.size.width, height: cell.bounds.size.height)
		cell.layoutSubviews()
		
		// Determines the best size of the view considering all constraints it holds
		// and those of its subviews.
		var height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
		if height == 0 {
			height = cell.bounds.size.height // zero result, uses cell's bounds
		}
		let separator = 1 / UIScreen.main.scale
		height += (tableView!.separatorStyle != .none ? separator : 0)
		
		// Cache value
		cachedRowHeights[row.hashValue] = height
		
		return height
	}
	
	
	/// Attempt to provide an estimate of the row's height automatically.
	///
	/// - Parameters:
	///   - row: the row to evaluate
	///   - indexPath: path of the row
	/// - Returns: estimated height
	private func estimatedHeight(forRow row: RowProtocol, at indexPath: IndexPath) -> CGFloat {
		if let height = self.cachedRowHeights[row.hashValue] {
			return height
		}
		
		if let estimatedHeight = row._estimatedHeight , estimatedHeight > 0 {
			return estimatedHeight
		}
		
		return self.tableView!.estimatedRowHeight
	}

	/// Clear cache's height
	private func clearHeightCache() {
		self.cachedRowHeights.removeAll()
		self.prototypesCells.removeAll()
	}

}

extension TableManager: UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidScroll?(scrollView)
	}
	
	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidZoom?(scrollView)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
	}
	
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
	}
	
	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return scrollViewDelegate?.viewForZooming?(in: scrollView)
	}
	
	public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		scrollViewDelegate?.scrollViewWillBeginZooming!(scrollView, with: view)
	}
	
	public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
		scrollViewDelegate?.scrollViewDidEndZooming!(scrollView, with: view, atScale: scale)
	}
	
	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
	}
	
	public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
	}
	
}
