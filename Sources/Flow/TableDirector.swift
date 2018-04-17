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
	
	public var headerHeight: CGFloat? = nil
	
	public var footerHeight: CGFloat? = nil

	public var onGetSectionForSectionIndex: ((_ title: String, _ index: Int) -> (Int))? = nil

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
		self.tableView?.reloadData()
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
		adapter._invoke(event: .dequeue, model, cell, indexPath, tableView, nil)
		return cell
	}
	
	// Header & Footer
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIdx: Int) -> UIView? {
		guard let header = sections[sectionIdx].headerView else { return nil }
		return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.reusableRegister.registerView(header))
	}
	
	public func tableView(_ tableView: UITableView, viewForFooterInSection sectionIdx: Int) -> UIView? {
		guard let footer = sections[sectionIdx].footerView else { return nil }
		return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.reusableRegister.registerView(footer))
	}
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sections[section].headerTitle
	}
	
	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.sections[section].footerTitle
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return self.sections[section].headerHeight ?? (self.headerHeight ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		guard let estHeight = self.sections[section].onGetHeaderHeight?() else {
			let height = self.sections[section].footerHeight ?? (self.footerHeight ?? UITableViewAutomaticDimension)
			return height
		}
		return estHeight
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		guard let estHeight = self.sections[section].onGetHeaderHeight?() else {
			let height = self.sections[section].headerHeight ?? (self.headerHeight ?? UITableViewAutomaticDimension)
			return height
		}
		return estHeight
	}
	
	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		self.sections[section].onWillDisplayHeader?(view)
	}
	
	public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		self.sections[section].onWillDisplayFooter?(view)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		guard section < self.sections.count else { return }
		self.sections[section].onDidEndDisplayFooter?(view)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		guard section < self.sections.count else { return }
		self.sections[section].onDidEndDisplayHeader?(view)
	}
	
	// Inserting or Deleting Table Rows
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .commitEdit, model, nil, indexPath, tableView, [.param1 : editingStyle])
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .canEdit, model, nil, indexPath, tableView, nil) as? Bool) ?? false)
	}
	
	// Reordering Table Rows

	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .canMoveRow, model, nil, indexPath, tableView, nil) as? Bool) ?? false)
	}

	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		adapter._invoke(event: .moveRow, model, nil, sourceIndexPath, tableView, [.param1 : destinationIndexPath])
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .rowHeight, model, nil, indexPath, tableView, nil) as? CGFloat) ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .rowHeightEstimated, model, nil, indexPath, tableView, nil) as? CGFloat) ?? UITableViewAutomaticDimension)
	}
	
	public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .indentLevel, model, nil, indexPath, tableView, nil) as? Int) ?? 1)
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .willDisplay, model, cell, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .shouldSpringLoad, model, nil, indexPath, tableView, nil) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .editActions, model, nil, indexPath, tableView, nil) as? [UITableViewRowAction])
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .tapOnAccessory, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .willSelect, model, nil, indexPath, tableView, nil) as? IndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .didSelect, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .willDeselect, model, nil, indexPath, tableView, nil) as? IndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .didDeselect, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .willBeginEdit, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		guard let index = indexPath else { return }
		let (model,adapter) = self.context(forItemAt: index)
		adapter._invoke(event: .didEndEdit, model, nil, indexPath!, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .editStyle, model, nil, indexPath, tableView, nil) as? UITableViewCellEditingStyle) ?? .none)
	}
	
	public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .deleteConfirmTitle, model, nil, indexPath, tableView, nil) as? String)
	}
	
	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .editShouldIndent, model, nil, indexPath, tableView, nil) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		let (model,adapter) = self.context(forItemAt: sourceIndexPath)
		return ((adapter._invoke(event: .moveAdjustDestination, model, nil, sourceIndexPath, tableView, [.param1 : proposedDestinationIndexPath]) as? IndexPath) ?? proposedDestinationIndexPath)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		self.adapters.forEach { data in
			(data.value as! TableAdaterProtocolFunctions)._invoke(event: .endDisplay, cell: cell, indexPath, tableView, nil)
		}
	}
	
	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .shouldShowMenu, model, nil, indexPath, tableView, nil) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .canPerformMenuAction, model, nil, indexPath, tableView, [.param1 : action, .param2 : sender]) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .performMenuAction, model, nil, indexPath, tableView, [.param1 : action, .param2: sender])
	}
	
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .shouldHighlight, model, nil, indexPath, tableView, nil) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .didHighlight, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._invoke(event: .didUnhighlight, model, nil, indexPath, tableView, nil)
	}
	
	public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return ((adapter._invoke(event: .canFocus, model, nil, indexPath, tableView, nil) as? Bool) ?? true)
	}
	
	public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .leadingSwipeActions, model, nil, indexPath, tableView, nil) as? UISwipeActionsConfiguration)
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return (adapter._invoke(event: .trailingSwipeActions, model, nil, indexPath, tableView, nil) as? UISwipeActionsConfiguration)
	}
	
	public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.tableIndexes()
	}
	
	public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		let indexes = (self.tableIndexes() ?? [])
		guard indexes.count != self.sections.count else { return index } // same items
		guard let mapFunction = self.onGetSectionForSectionIndex else {
			fatalError("Must implement onGetSectionForSectionIndex() on table director")
		}
		return mapFunction(title,index)
	}
	
	private func tableIndexes() -> [String]? {
		let indexes = self.sections.compactMap({ $0.indexTitle })
		guard indexes.count > 0 else { return nil }
		return indexes
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
			adapterGroup.adapter._invoke(event: .prefetch, adapterGroup.models, adapterGroup.indexPaths, tableView, nil)
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPath: indexPaths).forEach { adapterGroup in
			adapterGroup.adapter._invoke(event: .cancelPrefetch, adapterGroup.models, adapterGroup.indexPaths, tableView, nil)
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
		
		internal func registerView(_ view: AbstractTableHeaderFooterItem) -> String {
			let identifier = view.reuseIdentifier
			guard !self.headersFootersIDs.contains(identifier) else { return identifier}
			
			let bundle = Bundle(for: view.viewClass)
			if let _ = bundle.path(forResource: identifier, ofType: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				self.table?.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
			} else if view.registerAsClass {
				self.table?.register(view.viewClass, forCellReuseIdentifier: identifier)
			}
			return identifier
		}
		
	}
	
}
