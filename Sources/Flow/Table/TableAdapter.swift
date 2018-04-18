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

/// Adapter manages a model type with its associated view representation (a particular cell type).
public class TableAdapter<M: ModelProtocol, C: CellProtocol>: TableAdapterProtocol,TableAdaterProtocolFunctions {

	/// TableAdapterProtocol conformances
	public var modelType: Any.Type = M.self
	public var cellType: Any.Type = C.self
	public var cellReuseIdentifier: String { return C.reuseIdentifier }
	public var cellClass: AnyClass { return C.self }
	public var registerAsClass: Bool { return C.registerAsClass }
	
	public static func == (lhs: TableAdapter<M, C>, rhs: TableAdapter<M, C>) -> Bool {
		return 	(String(describing: lhs.modelType) == String(describing: rhs.modelType)) &&
				(String(describing: lhs.cellType) == String(describing: rhs.cellType))
	}
	
	/// Registered events for table
	internal var events = [TableAdapterEventKey: TableEventable]()

	/// Initialize a new adapter with optional configuration callback.
	///
	/// - Parameter configuration: configuration callback
	init(_ configuration: ((TableAdapter) -> (Void))? = nil) {
		configuration?(self)
	}
	
	//MARK: TableAdaterProtocolFunctions Protocol
	
	func _instanceCell(in table: UITableView, at indexPath: IndexPath?) -> UITableViewCell {
		guard let indexPath = indexPath else {
			let castedCell = self.cellClass as! UITableViewCell.Type
			let cellInstance = castedCell.init()
			return cellInstance
		}
		return table.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath)
	}
	
	/// Register a new event for table.
	///
	/// - Parameter event: event to register.
	/// - Returns: self instance to optionally chain another call.
	@discardableResult
	public func on(_ event: Event<M,C>) -> Self {
		self.events[event.name] = event
		return self
	}

	///MARK: Internal Methods
	
	func _invoke(event: TableAdapterEventKey, _ models: [ModelProtocol], _ paths: [IndexPath], _ table: UITableView, _ data: [EventArgument : Any?]?) -> Any? {
		switch event {
		case .prefetch:
			guard case .prefetch(let c)? = self.events[.prefetch] as? Event<M,C> else { return nil }
			c((models as! [M]),paths)
		case .cancelPrefetch:
			guard case .cancelPrefetch(let c)? = self.events[.cancelPrefetch] as? Event<M,C> else { return nil }
			c((models as! [M]),paths)
		default:
			break
		}
		return nil
	}
	
	func _invoke(event: TableAdapterEventKey, cell: CellProtocol, _ path: IndexPath, _ table: UITableView, _ data: [EventArgument : Any?]?) -> Any? {
		switch event {
		case .endDisplay:
			guard case .endDisplay(let c)? = self.events[.endDisplay] as? Event<M,C> else { return nil }
			c((cell as! C),path)
		default:
			break
		}
		return nil
	}
	
	
	func _invoke(event: TableAdapterEventKey,
				 _ model: ModelProtocol, _ cell: CellProtocol?, _ path: IndexPath, _ table: UITableView, _ data: [EventArgument : Any?]?) -> Any? {
		guard let _ = self.events[event] else { return nil }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, table: table)
		
		switch event {
		case .dequeue:
			guard case .dequeue(let c)? = self.events[.dequeue] as? Event<M,C> else {
				return nil
			}
			c(ctx)
		case .canEdit:
			guard case .canEdit(let c)? = self.events[.canEdit] as? Event<M,C> else {
				return false
			}
			return c(ctx)
		case .commitEdit:
			guard case .commitEdit(let c)? = self.events[.commitEdit] as? Event<M,C> else {
				return UITableViewCellEditingStyle.none
			}
			return c(ctx, (data![.param1] as! UITableViewCellEditingStyle))
		case .canMoveRow:
			guard case .canMoveRow(let c)? = self.events[.canMoveRow] as? Event<M,C> else { return false }
			return c(ctx)
		case .moveRow:
			guard case .moveRow(let c)? = self.events[.moveRow] as? Event<M,C> else { return nil }
			c(ctx, (data![.param1] as! IndexPath))
		case .rowHeight:
			guard case .rowHeight(let c)? = self.events[.rowHeight] as? Event<M,C> else { return nil }
			return c(ctx)
		case .rowHeightEstimated:
			guard case .rowHeightEstimated(let c)? = self.events[.rowHeightEstimated] as? Event<M,C> else { return nil }
			return c(ctx)
		case .indentLevel:
			guard case .indentLevel(let c)? = self.events[.indentLevel] as? Event<M,C> else { return nil }
			return c(ctx)
		case .willDisplay:
			guard case .willDisplay(let c)? = self.events[.willDisplay] as? Event<M,C> else { return nil }
			c(ctx)
		case .shouldSpringLoad:
			guard case .shouldSpringLoad(let c)? = self.events[.shouldSpringLoad] as? Event<M,C> else { return nil }
			return c(ctx)
		case .editActions:
			guard case .editActions(let c)? = self.events[.editActions] as? Event<M,C> else { return nil }
			return c(ctx)
		case .tapOnAccessory:
			guard case .tapOnAccessory(let c)? = self.events[.tapOnAccessory] as? Event<M,C> else { return nil }
			c(ctx)
		case .willSelect:
			guard case .willSelect(let c)? = self.events[.willSelect] as? Event<M,C> else { return nil }
			return c(ctx)
		case .didSelect:
			guard case .didSelect(let c)? = self.events[.didSelect] as? Event<M,C> else { return nil }
			return c(ctx)
		case .willDeselect:
			guard case .willDeselect(let c)? = self.events[.willDeselect] as? Event<M,C> else { return nil }
			return c(ctx)
		case .didDeselect:
			guard case .didDeselect(let c)? = self.events[.didDeselect] as? Event<M,C> else { return nil }
			c(ctx)
		case .willBeginEdit:
			guard case .willBeginEdit(let c)? = self.events[.willBeginEdit] as? Event<M,C> else { return nil }
			c(ctx)
		case .didEndEdit:
			guard case .didEndEdit(let c)? = self.events[.didEndEdit] as? Event<M,C> else { return nil }
			c(ctx)
		case .editStyle:
			guard case .editStyle(let c)? = self.events[.editStyle] as? Event<M,C> else { return nil }
			return c(ctx)
		case .deleteConfirmTitle:
			guard case .deleteConfirmTitle(let c)? = self.events[.deleteConfirmTitle] as? Event<M,C> else { return nil }
			return c(ctx)
		case .editShouldIndent:
			guard case .editShouldIndent(let c)? = self.events[.editShouldIndent] as? Event<M,C> else { return nil }
			return c(ctx)
		case .moveAdjustDestination:
			guard case .moveAdjustDestination(let c)? = self.events[.moveAdjustDestination] as? Event<M,C> else { return nil }
			return c(ctx,(data![.param1] as! IndexPath))
		case .shouldShowMenu:
			guard case .shouldShowMenu(let c)? = self.events[.shouldShowMenu] as? Event<M,C> else { return nil }
			return c(ctx)
		case .canPerformMenuAction:
			guard case .canPerformMenuAction(let c)? = self.events[.canPerformMenuAction] as? Event<M,C> else { return nil }
			return c(ctx, (data![.param1] as! Selector), (data?[.param2] ?? nil) )
		case .shouldHighlight:
			guard case .shouldHighlight(let c)? = self.events[.shouldHighlight] as? Event<M,C> else { return nil }
			return c(ctx)
		case .didHighlight:
			guard case .didHighlight(let c)? = self.events[.didHighlight] as? Event<M,C> else { return nil }
			c(ctx)
		case .didUnhighlight:
			guard case .didUnhighlight(let c)? = self.events[.didUnhighlight] as? Event<M,C> else { return nil }
			c(ctx)
		case .canFocus:
			guard case .canFocus(let c)? = self.events[.canFocus] as? Event<M,C> else { return nil }
			return c(ctx)
		case .leadingSwipeActions:
			guard case .leadingSwipeActions(let c)? = self.events[.leadingSwipeActions] as? Event<M,C> else { return nil }
			return c(ctx)
		case .trailingSwipeActions:
			guard case .trailingSwipeActions(let c)? = self.events[.trailingSwipeActions] as? Event<M,C> else { return nil }
			return c(ctx)
		case .performMenuAction:
			guard case .performMenuAction(let c)? = self.events[.performMenuAction] as? Event<M,C> else { return nil }
			c(ctx, (data![.param1] as! Selector), (data?[.param2] ?? nil) )
		default:
			break
		}
		
		return nil
	}
	
}

public extension TableAdapter {
	
	/// Context of the adapter.
	/// A context is sent when an event is fired and includes type-safe informations (context)
	/// related to triggered event.
	public struct Context<M,C> {

		/// Parent table
		public private(set) weak var table: UITableView?

		/// Index path
		public let indexPath: IndexPath
		
		/// Model instance
		public let model: M
		
		
		/// Cell instance
		/// NOTE: For some events cell instance is not reachable and may return `nil`.
		public var cell: C? {
			guard let c = _cell else {
				return table?.cellForRow(at: self.indexPath) as? C
			}
			return c
		}
		private let _cell: C?

		/// Instance a new context with given data.
		/// Init of these objects are reserved.
		internal init(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, table: UITableView) {
			self.model = model as! M
			self._cell = cell as? C
			self.indexPath = path
			self.table = table
		}
	}
	
}
