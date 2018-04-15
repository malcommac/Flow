//
//  TableAdapter.swift
//  Flow
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public protocol TableAdapterProtocol : AbstractAdapterProtocol, Equatable {
	
}

internal protocol TableAdaterProtocolFunctions {
	// Dequeue (UITableViewDatasource)
	func _instanceCell(in table: UITableView, at indexPath: IndexPath?) -> UITableViewCell
	func _onDequeue(model: ModelProtocol, cell: CellProtocol, path: IndexPath, table: UITableView)
	
	/// Inserting or Deleting Table Rows (UITableViewDatasource)
	func _canEdit(model: ModelProtocol, path: IndexPath, table: UITableView) -> Bool
	func _commitEdit(model: ModelProtocol, commit: UITableViewCellEditingStyle, path: IndexPath, table: UITableView)
	
	/// Reordering Table Rows (UITableViewDatasource)
	func _canMoveRow(model: ModelProtocol, path: IndexPath, table: UITableView) -> Bool
	func _moveRow(model: ModelProtocol, fromPath: IndexPath, toPath: IndexPath, table: UITableView)
	
	// Prefetching
	func _didPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], table: UITableView)
	func _didCancelPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], table: UITableView)
	
	// Configuring Rows for the Table View (UITableViewDelegate)
	func _heightForRow(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> CGFloat?
	func _estimatedHeightForRow(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> CGFloat?
	func _indentationLevel(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Int?
	func _willDisplay(model: ModelProtocol, cell: CellProtocol, indexPath: IndexPath, table: UITableView)
	func _shouldSpringLoad(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool?

	// Managing Accessory Views (UITableViewDelegate)
	func _editActions(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> [UITableViewRowAction]?
	func _accessoryTapped(model: ModelProtocol, indexPath: IndexPath, table: UITableView)

	// Managing Selections (UITableViewDelegate)
	func _willSelect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> IndexPath?
	func _didSelect(model: ModelProtocol, indexPath: IndexPath, table: UITableView)
	func _willDeselect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> IndexPath?
	func _didDeselect(model: ModelProtocol, indexPath: IndexPath, table: UITableView)

	// Editing Table Rows (UITableViewDelegate)
	func _willBeginEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView)
	func _didEndEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView)
	func _editingStyle(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UITableViewCellEditingStyle?
	func _deleteConfirmationTitle(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> String?
	func _shouldIdentWhileEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool?

	// Reordering Table Rows (UITableViewDelegate)
	func _adjustMoveDestination(model: ModelProtocol, from fromPath: IndexPath, to destPath: IndexPath, table: UITableView) -> IndexPath?

	// Tracking the Removal of Views (UITableViewDelegate)
	func _didEndDisplay(cell: UITableViewCell, indexPath: IndexPath, table: UITableView)

	// Copying and Pasting Row Content
	func _shouldShowMenu(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool
	func _canPerformAction(model: ModelProtocol, indexPath: IndexPath, selector: Selector, sender: Any?, table: UITableView) -> Bool
	func _performAction(model: ModelProtocol, indexPath: IndexPath, selector: Selector, sender: Any?, table: UITableView)

	// Managing Table View Highlighting
	func _shouldHighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool
	func _didHighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView)
	func _didUnhighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView)
	
	// Managing Table View Focus
	func _canFocus(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool

	// Handling Swipe Actions
	func _configureLeadingSwipe(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UISwipeActionsConfiguration?
	func _configureTrailingSwipe(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UISwipeActionsConfiguration?

}

public class TableAdapter<M: ModelProtocol, C: CellProtocol>: TableAdapterProtocol,TableAdaterProtocolFunctions {
	public typealias EventContextToVoid = ((Context<M,C>) -> Void)
	public typealias EventContextToBool = ((Context<M,C>) -> Bool)
	public typealias EventContextToFloat = ((Context<M,C>) -> CGFloat)
	public typealias EventContextToInt = ((Context<M,C>) -> Int)

	public var modelType: Any.Type = M.self
	
	public var cellType: Any.Type = C.self
	
	public var cellReuseIdentifier: String {
		return C.reuseIdentifier
	}
	
	public var cellClass: AnyClass {
		return C.self
	}
	
	public var registerAsClass: Bool {
		return C.registerAsClass
	}
	
	public static func == (lhs: TableAdapter<M, C>, rhs: TableAdapter<M, C>) -> Bool {
		return 	(String(describing: lhs.modelType) == String(describing: rhs.modelType)) &&
				(String(describing: lhs.cellType) == String(describing: rhs.cellType))
	}
	
	init(_ configuration: ((TableAdapter) -> (Void))? = nil) {
		configuration?(self)
	}
	
	
	public var onConfigure: EventContextToVoid? = nil
	
	///MARK: Events: Inserting or Deleting Table Rows
	public var onCanEdit: EventContextToBool? = nil
	public var onCommitEdit: ((_ context: Context<M,C>, _ commit: UITableViewCellEditingStyle) -> Void)? = nil

	///MARK: Events: Reordering Table Rows
	public var onCanMoveRow: EventContextToBool? = nil
	public var onMoveRow: ((_ context: Context<M,C>, _ destintion: IndexPath) -> Void)? = nil
	
	///MARK: Events: Prefetching data
	public var onCancelPrefetchFor: ((_ items: [M], _ paths: [IndexPath], _ table: UITableView) -> (Void))? = nil
	public var onRequestPrefetchFor: ((_ items: [M], _ paths: [IndexPath], _ table: UITableView) -> (Void))? = nil

	//MARK: Events: Configuring Rows for the Table View
	public var onGetRowHeight: EventContextToFloat? = nil
	public var onGetEstimatedRowHeight: EventContextToFloat? = nil
	public var onGetIndentationLevel: EventContextToInt? = nil
	public var onWillDisplay: EventContextToVoid? = nil
	public var onShouldSpringLoad: EventContextToBool? = nil
	
	//MARK: Events: Managing Accessory Views
	public var onGetEditActions: ((Context<M,C>) -> [UITableViewRowAction])? = nil
	public var onAccessoryTapped: EventContextToVoid? = nil
	
	//MARK: Events: Managing Selections
	public var onWillSelect: ((Context<M,C>) -> IndexPath?)? = nil
	public var onDidSelect: EventContextToVoid? = nil
	public var onWillDeselect: ((Context<M,C>) -> IndexPath?)? = nil
	public var onDidDeselect: EventContextToVoid? = nil
	
	//MARK: Events: Editing Table Rows
	public var onWillBeginEditing: EventContextToVoid? = nil
	public var onDidEndEditing: EventContextToVoid? = nil
	public var onGetEditingStyle: ((Context<M,C>) -> UITableViewCellEditingStyle)? = nil
	public var onGetDeleteConfirmationTitle: ((Context<M,C>) -> String?)? = nil
	public var onShouldIndentWhileEditing: EventContextToBool? = nil
	
	//MARK: Events: Reordering Table Rows
	public var onAdjustMoveDestination: ((_ context: Context<M,C>, _ proposed: IndexPath) -> IndexPath?)? = nil

	//MARK: Events: Tracking the Removal of Views
	public var onEndDisplay: ((_ cell: C, _ path: IndexPath) -> (Void))? = nil

	//MARK: Events: Copying and Pasting Row Content
	public var onShouldShowMenu: EventContextToBool? = nil
	public var onCanPerformAction: ((_ context: Context<M,C>, _ selector: Selector, _ sender: Any?) -> Bool)? = nil
	public var onPerformAction: ((_ context: Context<M,C>, _ selector: Selector, _ sender: Any?) -> Void)? = nil

	//MARK: Events: Managing Table View Highlighting
	public var onShouldHighlight: EventContextToBool? = nil
	public var onDidHighlight: EventContextToVoid? = nil
	public var onDidUnhighlight: EventContextToVoid? = nil
	
	//MARK: Events: Managing Table View Focus
	public var onCanFocus: EventContextToBool? = nil
	
	//MARK: Events: Handling Swipe Actions
	public var onGetLeadingSwipeActions: ((Context<M,C>) -> UISwipeActionsConfiguration?)? = nil
	public var onGetTrailingSwipeActions: ((Context<M,C>) -> UISwipeActionsConfiguration?)? = nil
	
	//MARK: TableAdaterProtocolFunctions Protocol
	
	func _instanceCell(in table: UITableView, at indexPath: IndexPath?) -> UITableViewCell {
		guard let indexPath = indexPath else {
			let castedCell = self.cellClass as! UITableViewCell.Type
			let cellInstance = castedCell.init()
			return cellInstance
		}
		return table.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath)
	}
	
	func _onDequeue(model: ModelProtocol, cell: CellProtocol, path: IndexPath, table: UITableView) {
		guard let event = self.onConfigure else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, table: table)
		event(ctx)
	}
	
	func _canEdit(model: ModelProtocol, path: IndexPath, table: UITableView) -> Bool {
		guard let event = self.onCanEdit else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, table: table)
		return event(ctx)
	}
	
	func _commitEdit(model: ModelProtocol, commit: UITableViewCellEditingStyle, path: IndexPath, table: UITableView) {
		guard let event = self.onCommitEdit else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, table: table)
		event(ctx,commit)
	}
	
	func _canMoveRow(model: ModelProtocol, path: IndexPath, table: UITableView) -> Bool {
		guard let event = self.onCanMoveRow else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, table: table)
		return event(ctx)
	}
	
	func _moveRow(model: ModelProtocol, fromPath: IndexPath, toPath: IndexPath, table: UITableView) {
		guard let event = self.onMoveRow else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: fromPath, table: table)
		return event(ctx,toPath)
	}
	
	func _didPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], table: UITableView) {
		guard let event = self.onRequestPrefetchFor else { return }
		return event(models as! [M],indexPaths,table)
	}
	
	func _didCancelPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], table: UITableView) {
		guard let event = self.onCancelPrefetchFor else { return }
		return event(models as! [M],indexPaths,table)
	}
	
	func _heightForRow(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> CGFloat? {
		guard let event = self.onGetRowHeight else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _estimatedHeightForRow(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> CGFloat? {
		guard let event = self.onGetEstimatedRowHeight else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _indentationLevel(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Int? {
		guard let event = self.onGetIndentationLevel else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _willDisplay(model: ModelProtocol, cell: CellProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onWillDisplay else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: indexPath, table: table)
		event(ctx)
	}
	
	func _shouldSpringLoad(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool? {
		guard let event = self.onShouldSpringLoad else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _editActions(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> [UITableViewRowAction]? {
		guard let event = self.onGetEditActions else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _accessoryTapped(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onAccessoryTapped else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _willSelect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> IndexPath? {
		guard let event = self.onWillSelect else { return indexPath }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _didSelect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onDidSelect else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _willDeselect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> IndexPath? {
		guard let event = self.onWillDeselect else { return indexPath }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _didDeselect(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onDidDeselect else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _willBeginEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onWillBeginEditing else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _didEndEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onDidEndEditing else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _editingStyle(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UITableViewCellEditingStyle? {
		guard let event = self.onGetEditingStyle else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _deleteConfirmationTitle(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> String? {
		guard let event = self.onGetDeleteConfirmationTitle else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _shouldIdentWhileEditing(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool? {
		guard let event = self.onShouldIndentWhileEditing else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _adjustMoveDestination(model: ModelProtocol, from fromPath: IndexPath, to destPath: IndexPath, table: UITableView) -> IndexPath? {
		guard let event = self.onAdjustMoveDestination else { return destPath }
		let ctx = Context<M,C>(model: model, cell: nil, path: fromPath, table: table)
		return event(ctx,destPath)
	}
	
	func _didEndDisplay(cell: UITableViewCell, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onEndDisplay, let c = cell as? C else { return }
		return event(c,indexPath)
	}
	
	func _shouldShowMenu(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool {
		guard let event = self.onShouldShowMenu else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _canPerformAction(model: ModelProtocol, indexPath: IndexPath, selector: Selector, sender: Any?, table: UITableView) -> Bool {
		guard let event = self.onCanPerformAction else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx,selector,sender)
	}
	
	func _performAction(model: ModelProtocol, indexPath: IndexPath, selector: Selector, sender: Any?, table: UITableView) {
		guard let event = self.onPerformAction else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx,selector,sender)
	}

	func _shouldHighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool {
		guard let event = self.onShouldHighlight else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _didHighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onDidHighlight else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _didUnhighlight(model: ModelProtocol, indexPath: IndexPath, table: UITableView) {
		guard let event = self.onDidUnhighlight else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		event(ctx)
	}
	
	func _canFocus(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> Bool {
		guard let event = self.onCanFocus else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _configureLeadingSwipe(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UISwipeActionsConfiguration? {
		guard let event = self.onGetLeadingSwipeActions else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
	func _configureTrailingSwipe(model: ModelProtocol, indexPath: IndexPath, table: UITableView) -> UISwipeActionsConfiguration? {
		guard let event = self.onGetTrailingSwipeActions else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: indexPath, table: table)
		return event(ctx)
	}
	
}

public extension TableAdapter {
	
	public struct Context<M,C> {
		
		public let indexPath: IndexPath
		public let model: M
		public private(set) weak var table: UITableView?
		private let _cell: C?
		
		public var cell: C? {
			guard let c = _cell else {
				return table?.cellForRow(at: self.indexPath) as? C
			}
			return c
		}
		internal init(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, table: UITableView) {
			self.model = model as! M
			self._cell = cell as? C
			self.indexPath = path
			self.table = table
		}
	}
	
}
