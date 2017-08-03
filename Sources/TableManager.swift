//
//	Flow: Manage Tables Easily
//	--------------------------------------
//	Created by:	Daniele Margutti
//	Email:		hello@danielemargutti.com
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

open class TableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
	
	/// This represent which table should be managed by this instance
	private(set) weak var tableView: UITableView?
	
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
	                   _ block: @escaping ((Void) -> (Void))) {
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
			self.sections.append(Section(rows: rows))
		}
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
			self.sections.append(Section(rows: [row]))
		}
		return self
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
		self.sections.remove(at: index)
		return self
	}
	
	/// Remove all sections from the table
	///
	/// - Returns: self
	@discardableResult
	public func removeAll() -> Self {
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
	
	/// Cell for a particular `indexPath` in target table
	///
	/// - Parameters:
	///   - tableView: target table
	///   - indexPath: index path for the cell
	/// - Returns: a dequeued cell
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Identify the row to allocate, register if necessary
		let row = self.row(forIndexPath: indexPath)
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
		let row = self.row(forIndexPath: indexPath)
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
		let row = self.row(forIndexPath: indexPath)
		return self.rowHeight(forRow: row, at: indexPath, estimate: true)
	}
	
	/// Simple header string
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: header string if present, `nil` otherwise
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return (self.sections[section]).headerTitle
	}
	
	/// Simple footer string
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: footer string if present, `nil` otherwise
	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return (self.sections[section]).footerTitle
	}
	
	/// Custom view to represent the header of a section
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: header view to use (it overrides header string if set)
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return (self.sections[section]).headerView?.view
	}
	
	/// Custom view to represent the footer of a section
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: footer view to use (it overrides footer string if set)
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return (self.sections[section]).footerView?.view
	}
	
	/// Height of the header for a section. It will be used only for header's custom view
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the height of the header
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let current_section = (self.sections[section])
		// If no header is specified we can rely to the automatic row dimension
		guard let header_view = current_section.headerView else {
			return UITableViewAutomaticDimension
		}
		// If a fixed height is specified we can use it,
		// otherwise extract it from the instance of the header view
		return header_view.height ?? header_view.view.frame.size.height
	}
	
	/// Height of the footer for a section. It will be used only for footer's custom view
	///
	/// - Parameters:
	///   - tableView: target table
	///   - section: section
	/// - Returns: the height of the footer instance
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let current_section = (self.sections[section])
		// If no footer is specified we can rely to the automatic row dimension
		guard let footer_view = current_section.footerView else {
			return UITableViewAutomaticDimension
		}
		// If a fixed height is specified we can use it,
		// otherwise extract it from the instance of the footer view
		return footer_view.height ?? footer_view.view.frame.size.height
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
		let row = self.row(forIndexPath: indexPath) // represented model of the row

		if let onWillSelect = row.onWillSelect {
			return onWillSelect(cell,indexPath)
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
		let row = self.row(forIndexPath: indexPath) // represented model of the row
		
		let select_behaviour = row.onTap?(cell,indexPath) ?? .deselect(true)
		switch select_behaviour {
		case .deselect(let animated):
			// remove selection, is a temporary tap selection
			tableView.deselectRow(at: indexPath, animated: animated)
		case .keepSelection:
			row.onSelect?(cell,indexPath) // dispatch selection change event
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
		let row = self.row(forIndexPath: indexPath) // represented model of the row
		row.onDeselect?(cell,indexPath)
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
		let row = self.row(forIndexPath: indexPath)
		row.onWillDisplay?(cell,indexPath)
	}
	
	
	/// Asks the delegate if the specified row should be highlighted
	///
	/// - Parameters:
	///   - tableView: The table-view object that is making this request.
	///   - indexPath: The index path of the row being highlighted.
	/// - Returns: `true` or `false`.
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.row(forIndexPath: indexPath)
		return row.onShouldHighlight?(cell,indexPath) ?? true
	}
	
	
	/// Asks the data source to verify that the given row is editable.
	///
	/// - Parameters:
	///   - tableView: The table-view object requesting this information.
	///   - indexPath: An index path locating a row in tableView.
	/// - Returns: true if the row indicated by indexPath is editable; otherwise, false.
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let cell = tableView.cellForRow(at: indexPath)
		let row = self.row(forIndexPath: indexPath)
		// If no actions are definined cell is not editable
		return row.onEdit?(cell,indexPath)?.count ?? 0 > 0
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
		let row = self.row(forIndexPath: indexPath)
		return row.onEdit?(cell,indexPath) ?? nil
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
		let row = self.row(forIndexPath: indexPath)
		row.onDelete?(cell,indexPath)
	}
	
	///MARK: Private Helper Methods
	
	
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
	
	private func adjustLayout(forCell cell: UITableViewCell) {
		guard cell.frame.size.width != self.tableView!.frame.size.width else {
			return
		}
		cell.frame = CGRect(x: 0, y: 0, width: self.tableView!.frame.size.width, height: cell.frame.size.height)
		cell.layoutIfNeeded()
	}
	
	private func row(forIndexPath indexPath: IndexPath) -> RowProtocol {
		return self.sections[indexPath.section].rows[indexPath.row]
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
		if let _ = sourceBundle.path(forResource: reuseIdentifier, ofType: "xib") {
			let nib = UINib(nibName: reuseIdentifier, bundle: sourceBundle)
			tableView?.register(nib, forCellReuseIdentifier: reuseIdentifier)
		} else {
			tableView?.register(cell, forCellReuseIdentifier: reuseIdentifier)
		}
		
		self.registeredCellIDs.insert(reuseIdentifier)
	}
	
	private func rowHeight(forRow row: RowProtocol, at indexPath: IndexPath, estimate: Bool = false) -> CGFloat {
		let row = self.sections[indexPath.section].rows[indexPath.row]

		/// User provided a function to evaluate the height of the table
		if row.evaluateRowHeight != nil {
			if let height = row.evaluateRowHeight!() {
				return height
			}
		}
		
		/// User provided the height of the table at class level (static based)
		if let static_height = row.defaultHeight {
			return static_height
		}
		
		/// Attempt to estimate the height of the row automatically
		if self.estimateRowSizeAutomatically == true {
			if estimate == true {
				return self.estimatedHeight(forRow: row, at: indexPath)
			} else {
				return self.height(forRow: row, at: indexPath)
			}
		}

		// universal fallback to automatic dimenion
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
		
		if let estimatedHeight = row.estimatedHeight , estimatedHeight > 0 {
			return estimatedHeight
		}
		
		return UITableViewAutomaticDimension
	}

	/// Clear cache's height
	private func clearHeightCache() {
		self.cachedRowHeights.removeAll()
		self.prototypesCells.removeAll()
	}
}
