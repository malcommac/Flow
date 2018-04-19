//
//	Flow
//	A declarative approach to UICollectionView & UITableView management
//	--------------------------------------------------------------------
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

public class TableDirector: NSObject, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	
	/// Height of the row
	///
	/// - `default`: both `rowHeight`,`estimatedRowHeight` are set to `UITableViewAutomaticDimension`
	/// - automatic: automatic using autolayout. You can provide a valid estimated value.
	/// - fixed: fixed value. If all of your cells are the same height set it to fixed in order to improve the performance of the table.
	public enum RowHeight {
		case `default`
		case autoLayout(estimated: CGFloat)
		case fixed(height: CGFloat)
	}
	
	/// Managed table view
	public private(set) weak var tableView: UITableView?

	/// Registered adapters for managed tables
	public private(set) var adapters: [String: AbstractAdapterProtocol] = [:]

	/// Registered cell reusable identifiers
	private var cellIDs: Set<String> = []
	
	/// Visible sections of the table
	public private(set) var sections: [TableSection] = []
	
	/// Registered header/footer's view reusable identifiers
	private var headersFootersIDs: Set<String> = []
	
	/// Height of headers into the table.
	/// This parameter maybe overriden by single TableSection's `headerHeight` event.
	public var headerHeight: CGFloat? = nil
	
	/// Height of footers into the table.
	/// This parameter maybe overriden by single TableSection's `footerHeight` event.
	public var footerHeight: CGFloat? = nil
	
	/// Registered events for director
	private var events = [TableDirectorEventKey: TableDirectorEventable]()
	
	/// Set the height of the row.
	public var rowHeight: RowHeight = .`default` {
		didSet {
			switch rowHeight {
			case .fixed(let h):
				self.tableView?.rowHeight = h
				self.tableView?.estimatedRowHeight = h
			case .autoLayout(let estimate):
				self.tableView?.rowHeight = UITableViewAutomaticDimension
				self.tableView?.estimatedRowHeight = estimate
			case .default:
				self.tableView?.rowHeight = UITableViewAutomaticDimension
				self.tableView?.estimatedRowHeight = UITableViewAutomaticDimension
			}
		}
	}
	
	/// Set it `true` to enable cell's prefetch. You must register `prefetch` and `cancelPrefetch`
	/// events inside enabled sections.
	public var prefetchEnabled: Bool {
		set {
			switch newValue {
			case true: 	self.tableView!.prefetchDataSource = self
			case false: self.tableView!.prefetchDataSource = nil
			}
		}
		get {
			return (self.tableView!.prefetchDataSource != nil)
		}
	}
	
	/// Initialize a new director for given table.
	///
	/// - Parameter table: table manager
	public init(_ table: UITableView) {
		super.init()
		self.tableView = table
		self.rowHeight = .default
		table.delegate = self
		table.dataSource = self
	}
	
	/// Register a new adapter's for table.
	/// Adapter manage a single model type and associate it to a visual representation (a cell).
	///
	/// - Parameter adapter: adapter to register
	public func register(adapter: AbstractAdapterProtocol) {
		let modelID = String(describing: adapter.modelType)
		self.adapters[modelID] = adapter // register adapter
		self.registerCell(forAdapter: adapter)
	}
	
	/// Register a new event for table.
	///
	/// - Parameter event: event to register.
	/// - Returns: self instance to optionally chain another call.
	@discardableResult
	public func on(_ event: TableDirector.Event) -> Self {
		self.events[event.name] = event
		return self
	}
	
	/// Reload contents of table.
	///
	/// - Parameters:
	///   - task: specify a callback where you can modify the structure of the table (sections & items). At the end of the block automatic
	///			  diffing is performed and a reload is made with using table's animation configuration (`TableReloadAnimations`). If `nil` is
	///			  returned the `TableReloadAnimations.default()` automatic animation is made.
	///   - onEnd: optional callback called at the end of the reload.
	public func reload(after task: (() -> (TableReloadAnimations?))? = nil, onEnd: (() -> (Void))? = nil) {
		guard let t = task else {
			self.tableView?.reloadData()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { onEnd?() })
			return
		}
		
		// Keep a reference to removed items in order to perform diff and animation
		let oldSections: [TableSection] = Array.init(self.sections)
		var oldItemsInSections: [String: [ModelProtocol]] = [:]
		self.sections.forEach { oldItemsInSections[$0.UUID] = Array($0.items) }

		// Execute callback and return animations to perform
		let animationsToPerform = (t() ?? TableReloadAnimations.default())

		// Execute reload for sections
		let changesInSection = SectionChanges.fromTableSections(old: oldSections, new: self.sections)
		changesInSection.applyChanges(toTable: self.tableView, withAnimations: animationsToPerform)
		
		// Execute reload for items in remaining sections
		self.tableView?.beginUpdates()
		self.sections.enumerated().forEach { (idx,newSection) in
			if let oldSectionItems = oldItemsInSections[newSection.UUID] {
				let diffData = diff(old: (oldSectionItems as! [AnyHashable]), new: (newSection.items as! [AnyHashable]))
				let itemChanges = SectionItemsChanges.create(fromChanges: diffData, section: idx)
				itemChanges.applyChangesToSectionItems(ofTable: self.tableView, withAnimations: animationsToPerform)
			}
		}
		
		self.tableView?.endUpdates()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { onEnd?() })
	}
	
	/// Append a new section a the end of the table with passed items.
	///
	/// - Parameter items: items to add into the section.
	/// - Returns: created section
	@discardableResult
	public func add(items: [ModelProtocol]) -> TableSection {
		let section = TableSection(items)
		self.sections.append(section)
		return section
	}
	
	/// Insert a new section at given index.
	///
	/// - Parameters:
	///   - section: section to insert.
	///   - index: destination index; if index is invalid or `nil` section is append to the list.
	public func add(_ section: TableSection, at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(section)
			return
		}
		self.sections.insert(section, at: i)
	}
	
	/// Insert sections starting at given index.
	///
	/// - Parameters:
	///   - sections: sections to insert.
	///   - index: destination starting index; if index is invalid or `nil` sections are append to the list.
	public func add(_ sections: [TableSection], at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(contentsOf: sections)
			return
		}
		self.sections.insert(contentsOf: sections, at: i)
	}
	
	/// Remove all sections from the table.
	///
	/// - Parameter kp: `true` to keep the capacity and optimize operations.
	/// - Returns: removed sections.
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = self.sections.count
		self.sections.removeAll(keepingCapacity: kp)
		return count
	}
	
	/// Remove section at given index.
	///
	/// - Parameter index: index of the section to remove
	/// - Returns: removed section, if index is valid, `nil` otherwise.
	@discardableResult
	public func remove(at index: Int) -> TableSection? {
		guard index < self.sections.count else { return nil }
		return self.sections.remove(at: index)
	}
	
	/// Remove sections at given indexes.
	///
	/// - Parameter indexes: indexes of the sections to remove.
	/// - Returns: removed sections in order.
	@discardableResult
	public func remove(at indexes: IndexSet) -> [TableSection] {
		var removed: [TableSection] = []
		indexes.reversed().forEach {
			if $0 < self.sections.count {
				removed.append(self.sections.remove(at: $0))
			}
		}
		return removed
	}
	
	//MARK: Internal Functions
	
	/// Return the context of operation which includes model instance and associated adapter.
	///
	/// - Parameter index: index of target item.
	/// - Returns: model and adapter
	internal func context(forItemAt index: IndexPath) -> (ModelProtocol, TableAdaterProtocolFunctions) {
		let item: ModelProtocol = self.sections[index.section].items[index.row]
		let modelID = String(describing: type(of: item.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an adapter for model: \(modelID)")
		}
		return (item,adapter as! TableAdaterProtocolFunctions)
	}
	
	/// Return the adapter associated with type of model.
	/// Throw a fatal error if no adapter is created to manage passed model's type.
	///
	/// - Parameter model: model to read.
	/// - Returns: adapter.
	internal func context(forModel model: ModelProtocol) -> TableAdaterProtocolFunctions {
		let modelID = String(describing: type(of: model.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an adapter for \(modelID)")
		}
		return (adapter as! TableAdaterProtocolFunctions)
	}
	
	/// Return the list of adapters used to manage objects at given paths.
	/// Returned list is composed by `PrefetchModelsGroup` objects per each model's type
	/// and includes paths, models instances and associated adapter instance.
	///
	/// - Parameter paths: paths of (optionally eterogeneous) paths to objects.
	/// - Returns: `PrefetchModelsGroup` instance for each involved adapter.
	internal func adapters(forIndexPaths paths: [IndexPath]) -> [PrefetchModelsGroup] {
		var list: [String: PrefetchModelsGroup] = [:]
		paths.forEach { indexPath in
			let model = self.sections[indexPath.section].items[indexPath.item]
			let modelID = String(describing: type(of: model.self))
			
			var context: PrefetchModelsGroup? = list[modelID]
			if context == nil {
				context = PrefetchModelsGroup(adapter: self.adapters[modelID] as! TableAdaterProtocolFunctions)
				list[modelID] = context
			}
			context!.models.append(model)
			context!.indexPaths.append(indexPath)
		}
		
		return Array(list.values)
	}
	
	/// PrefetchModelsGroup groups models instances with given adapters.
	/// Instances of these objects are returned by `adapters(forIndexPaths)` function.
	internal class PrefetchModelsGroup {
		let adapter: 	TableAdaterProtocolFunctions
		var models: 	[ModelProtocol] = []
		var indexPaths: [IndexPath] = []
		
		public init(adapter: TableAdaterProtocolFunctions) {
			self.adapter = adapter
		}
	}
}


// MARK: - TableDirector UITableViewDataSource/UITableViewDelegate
public extension TableDirector {
	
	//MARK: UITableViewDataSource
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.sections[section].items.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let (model,adapter) = self.context(forItemAt: indexPath)
		let cell = adapter._instanceCell(in: tableView, at: indexPath)
		adapter.dispatch(.dequeue, context: InternalContext(model, indexPath, cell, tableView))
		return cell
	}
	
	// Header & Footer
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIdx: Int) -> UIView? {
		guard let header = sections[sectionIdx].headerView else { return nil }
		return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.registerView(header))
	}
	
	public func tableView(_ tableView: UITableView, viewForFooterInSection sectionIdx: Int) -> UIView? {
		guard let footer = sections[sectionIdx].footerView else { return nil }
		return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.registerView(footer))
	}
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sections[section].headerTitle
	}
	
	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.sections[section].footerTitle
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let h = self.sections[section].on.headerHeigth else {
			return (self.headerHeight ?? UITableViewAutomaticDimension)
		}
		return h()
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		guard let h = self.sections[section].on.footerHeight else {
			return (self.headerHeight ?? UITableViewAutomaticDimension)
		}
		return h()
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		guard let h = self.sections[section].on.estimatedHeaderHeight else {
			return (self.headerHeight ?? UITableViewAutomaticDimension)
		}
		return h()
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		guard let h = self.sections[section].on.estimatedFooterHeight else {
			return (self.footerHeight ?? UITableViewAutomaticDimension)
		}
		return h()
	}
	
	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		self.sections[section].on.willDisplayHeader?(view)
	}
	
	public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		self.sections[section].on.willDisplayFooter?(view)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		guard section < self.sections.count else { return }
		self.sections[section].on.didEndDisplayFooter?(view)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		guard section < self.sections.count else { return }
		self.sections[section].on.didEndDisplayHeader?(view)
	}
	
	// Inserting or Deleting Table Rows
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.commitEdit, context: InternalContext(model, indexPath, nil, tableView, param1: editingStyle))
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.canEdit, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? false)
	}
	
	// Reordering Table Rows

	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.canMoveRow, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? false)
	}

	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		adapter.dispatch(.moveRow, context: InternalContext(model, sourceIndexPath, nil, tableView, param1: destinationIndexPath))
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if case .fixed(let h) = self.rowHeight {
			return h
		}
		
		switch self.rowHeight {
		case .default:
			let (model,adapter) = self.context(forItemAt: indexPath)
			return (adapter.dispatch(.rowHeight, context: InternalContext(model, indexPath, nil, tableView)) as? CGFloat) ?? UITableViewAutomaticDimension
		case .autoLayout(_):
			return UITableViewAutomaticDimension
		default:
			return self.tableView!.rowHeight
		}
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.rowHeightEstimated, context: InternalContext(model, indexPath, nil, tableView)) as? CGFloat) ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.indentLevel, context: InternalContext(model,indexPath, nil, tableView)) as? Int) ?? 1)
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.willDisplay, context: InternalContext.init(model, indexPath, cell, tableView))
	}
	
	public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.shouldSpringLoad, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter.dispatch(.editActions, context: InternalContext(model, indexPath, nil, tableView)) as? [UITableViewRowAction]
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.tapOnAccessory, context: InternalContext(model, indexPath, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.willSelect, context: InternalContext(model, indexPath, nil, tableView)) as? IndexPath) ?? indexPath)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		
		let action = ((adapter.dispatch(.didSelect, context: InternalContext(model,indexPath,nil,tableView)) as? TableSelectionState) ?? .none)
		switch action {
		case .deselect:			tableView.deselectRow(at: indexPath, animated: false)
		case .deselectAnimated:	tableView.deselectRow(at: indexPath, animated: true)
		default:				break
		}
	}

	public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter.dispatch(.willDeselect, context: InternalContext(model, indexPath, nil, tableView)) as? IndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.didDeselect, context: InternalContext(model, indexPath, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.willBeginEdit, context: InternalContext(model, indexPath, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		guard let index = indexPath else { return }
		let (model,adapter) = self.context(forItemAt: index)
		adapter.dispatch(.didEndEdit, context: InternalContext(model, indexPath!, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.editStyle, context: InternalContext(model, indexPath, nil, tableView)) as? UITableViewCellEditingStyle) ?? .none)
	}
	
	public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter.dispatch(.deleteConfirmTitle, context: InternalContext(model, indexPath, nil, tableView)) as? String)
	}
	
	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.editShouldIndent, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		return ((adapter.dispatch(.moveAdjustDestination, context: InternalContext.init(model, sourceIndexPath, nil, tableView, param1: proposedDestinationIndexPath)) as? IndexPath) ?? proposedDestinationIndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		self.adapters.forEach {
			($0.value as! TableAdaterProtocolFunctions).dispatch(.endDisplay, context: InternalContext(nil, indexPath, cell, tableView))
		}
	}
	
	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.shouldShowMenu, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? false)
	}
	
	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.canPerformMenuAction, context: InternalContext(model, indexPath, nil, tableView, param1: action, param2: sender)) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.performMenuAction, context: InternalContext(model, indexPath, nil, tableView, param1: action, param2: sender))
	}
	
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.shouldHighlight, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.didHighlight, context: InternalContext(model, indexPath, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter.dispatch(.didUnhighlight, context: InternalContext(model, indexPath, nil, tableView))
	}
	
	public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter.dispatch(.canFocus, context: InternalContext(model, indexPath, nil, tableView)) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter.dispatch(.leadingSwipeActions, context: InternalContext.init(model, indexPath, nil, tableView)) as? UISwipeActionsConfiguration
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter.dispatch(.trailingSwipeActions, context: InternalContext.init(model, indexPath, nil, tableView)) as? UISwipeActionsConfiguration
	}
	
	/// Indexes
	
	public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.tableIndexes()
	}
	
	public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		let indexes = (self.tableIndexes() ?? [])
		guard indexes.count != self.sections.count else { return index } // same items
		
		guard case .sectionForSectionIndex(let c)? = self.events[.sectionForSectionIndex] as? TableDirector.Event else {
			fatalError("You must implement TableDirector's `sectionForSectionIndex` event if you use `indexTitle` from sections.")
		}
		return c(title,index)
	}
		
	private func tableIndexes() -> [String]? {
		let indexes = self.sections.compactMap({ $0.indexTitle })
		guard indexes.count > 0 else { return nil }
		return indexes
	}
	
	/// Prefetch Support
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPaths: indexPaths).forEach {
			$0.adapter.dispatch(.prefetch, context: InternalContext($0.models, $0.indexPaths, tableView))
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPaths: indexPaths).forEach {
			$0.adapter.dispatch(.cancelPrefetch, context: InternalContext($0.models, $0.indexPaths, tableView))
		}
	}
	
}


// MARK: - TableDirector Cell/ReusableView Registration Support

public extension TableDirector {
	
	/// Register a new cell for given adapter.
	///
	/// - Parameter adapter: adapter
	/// - Returns: `true` if cell is registered, `false` otherwise. If cell is already registered it returns `false`.
	@discardableResult
	internal func registerCell(forAdapter adapter: AbstractAdapterProtocol) -> Bool {
		let identifier = adapter.cellReuseIdentifier
		guard !cellIDs.contains(identifier) else {
			return false
		}
		let bundle = Bundle.init(for: adapter.cellClass)
		if let _ = bundle.path(forResource: identifier, ofType: "nib") {
			let nib = UINib(nibName: identifier, bundle: bundle)
			self.tableView?.register(nib, forCellReuseIdentifier: identifier)
		} else if adapter.registerAsClass {
			self.tableView?.register(adapter.cellClass, forCellReuseIdentifier: identifier)
		}
		cellIDs.insert(identifier)
		return true
	}
	
	/// Register a new reusable view for header/footer.
	///
	/// - Parameter view: abstract view to register.
	/// - Returns: `true` if view is registered, `false` otherwise. If view is already registered it returns `false`.
	internal func registerView(_ view: AbstractTableHeaderFooterItem) -> String {
		let identifier = view.reuseIdentifier
		guard !self.headersFootersIDs.contains(identifier) else { return identifier}
		
		let bundle = Bundle(for: view.viewClass)
		if let _ = bundle.path(forResource: identifier, ofType: "nib") {
			let nib = UINib(nibName: identifier, bundle: bundle)
			self.tableView?.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
		} else if view.registerAsClass {
			self.tableView?.register(view.viewClass, forCellReuseIdentifier: identifier)
		}
		return identifier
	}
	
	
}
