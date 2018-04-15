//
//  TableDirector.swift
//  Flow
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public class TableDirector: NSObject, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	
	public private(set) weak var tableView: UITableView?
	
	public private(set) var sections: [TableSection] = []

	public private(set) var adapters: [String: AbstractAdapterProtocol] = [:]

	public private(set) var reusableRegister: TableDirector.ReusableRegister

	public var prefetchEnabled: Bool {
		set {
			switch newValue {
			case true: self.tableView!.prefetchDataSource = self
			case false: self.tableView!.prefetchDataSource = nil
			}
		}
		get {
			return (self.tableView!.prefetchDataSource != nil)
		}
	}
	
	public init(_ table: UITableView) {
		self.reusableRegister = TableDirector.ReusableRegister(table)
		super.init()
		self.tableView = table
		self.tableView?.delegate = self
		self.tableView?.dataSource = self
	}
	
	public func register(adapter: AbstractAdapterProtocol) {
		let modelID = String(describing: adapter.modelType)
		self.adapters[modelID] = adapter // register adapter
		self.reusableRegister.registerCell(forAdapter: adapter) // register associated cell types into the collection
	}
	
	public func reload(after task: (() -> (Void))? = nil, onEnd: (() -> (Void))? = nil) {
		guard let t = task else {
			self.tableView?.reloadData()
			return
		}
	}
	
	@discardableResult
	public func add(items: [ModelProtocol]) -> TableSection {
		let section = TableSection(items)
		self.sections.append(section)
		return section
	}
	
	public func add(_ section: TableSection, at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(section)
			return
		}
		self.sections.insert(section, at: i)
	}
	
	public func add(_ sections: [TableSection], at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(contentsOf: sections)
			return
		}
		self.sections.insert(contentsOf: sections, at: i)
	}
	
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = self.sections.count
		self.sections.removeAll(keepingCapacity: kp)
		return count
	}
	
	@discardableResult
	public func remove(at index: Int) -> TableSection? {
		guard index < self.sections.count else { return nil }
		return self.sections.remove(at: index)
	}
	
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
	
	internal func context(forItemAt index: IndexPath) -> (ModelProtocol, TableAdaterProtocolFunctions) {
		let item: ModelProtocol = self.sections[index.section].items[index.row]
		let modelID = String(describing: type(of: item.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an adapter for model: \(modelID)")
		}
		return (item,adapter as! TableAdaterProtocolFunctions)
	}
	
	internal func context(forModel model: ModelProtocol) -> TableAdaterProtocolFunctions {
		let modelID = String(describing: type(of: model.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an adapter for \(modelID)")
		}
		return (adapter as! TableAdaterProtocolFunctions)
	}
	
	internal func adapters(forIndexPath paths: [IndexPath]) -> [PrefetchModelsGroup] {
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
		adapter._onDequeue(model: model, cell: cell, path: indexPath, table: tableView)
		return cell
	}
	
	// Inserting or Deleting Table Rows
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._commitEdit(model: model, commit: editingStyle, path: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canEdit(model: model, path: indexPath, table: tableView)
	}
	
	// Reordering Table Rows

	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canMoveRow(model: model, path: indexPath, table: tableView)
	}

	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		adapter._moveRow(model: model, fromPath: sourceIndexPath, toPath: destinationIndexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._heightForRow(model: model, indexPath: indexPath, table: tableView) ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._estimatedHeightForRow(model: model, indexPath: indexPath, table: tableView) ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._indentationLevel(model: model, indexPath: indexPath, table: tableView) ?? 1)
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._willDisplay(model: model, cell: cell, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._shouldSpringLoad(model: model, indexPath: indexPath, table: tableView) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._editActions(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._accessoryTapped(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._willSelect(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didDeselect(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._willDeselect(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didDeselect(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._willBeginEditing(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		guard let index = indexPath else { return }
		let (model,adapter) = self.context(forItemAt: index)
		adapter._didEndEditing(model: model, indexPath: index, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._editingStyle(model: model, indexPath: indexPath, table: tableView) ?? .none)
	}
	
	public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._deleteConfirmationTitle(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._shouldIdentWhileEditing(model: model, indexPath: indexPath, table: tableView) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		return (adapter._adjustMoveDestination(model: model, from: sourceIndexPath, to: proposedDestinationIndexPath, table: tableView) ?? proposedDestinationIndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		self.adapters.forEach { data in
			(data.value as! TableAdaterProtocolFunctions)._didEndDisplay(cell: cell, indexPath: indexPath, table: tableView)
		}
	}
	
	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldShowMenu(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canPerformAction(model: model, indexPath: indexPath, selector: action, sender: sender, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._performAction(model: model, indexPath: indexPath, selector: action, sender: sender, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldHighlight(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didHighlight(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didUnhighlight(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canFocus(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._configureLeadingSwipe(model: model, indexPath: indexPath, table: tableView)
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._configureTrailingSwipe(model: model, indexPath: indexPath, table: tableView)
	}
	
	// Prefetch
	
	internal class PrefetchModelsGroup {
		let adapter: 	TableAdaterProtocolFunctions
		var models: 	[ModelProtocol] = []
		var indexPaths: [IndexPath] = []
		
		public init(adapter: TableAdaterProtocolFunctions) {
			self.adapter = adapter
		}
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPath: indexPaths).forEach { adapterGroup in
			adapterGroup.adapter._didPrefetchItems(models: adapterGroup.models, indexPaths: adapterGroup.indexPaths, table: tableView)
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPath: indexPaths).forEach { adapterGroup in
			adapterGroup.adapter._didCancelPrefetchItems(models: adapterGroup.models, indexPaths: adapterGroup.indexPaths, table: tableView)
		}
	}
	
}


public extension TableDirector {
	
	public class ReusableRegister {
		
		public private(set) weak var table: UITableView?
		
		public private(set) var cellIDs: Set<String> = []
		
		public private(set) var headersFootersIDs: Set<String> = []
		
		internal init(_ table: UITableView) {
			self.table = table
		}
		
		@discardableResult
		internal func registerCell(forAdapter adapter: AbstractAdapterProtocol) -> Bool {
			let identifier = adapter.cellReuseIdentifier
			guard !cellIDs.contains(identifier) else {
				return false
			}
			let bundle = Bundle.init(for: adapter.cellClass)
			if let _ = bundle.path(forResource: identifier, ofType: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				table?.register(nib, forCellReuseIdentifier: identifier)
			} else if adapter.registerAsClass {
				table?.register(adapter.cellClass, forCellReuseIdentifier: identifier)
			}
			cellIDs.insert(identifier)
			return true
		}
		
		
	}
	
}
