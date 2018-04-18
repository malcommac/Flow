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

/// The adapter identify a pair of model and cell used to represent the data.
public class CollectionAdapter<M: ModelProtocol, C: CellProtocol>: CollectionAdapterProtocol, CustomStringConvertible, AbstractAdapterProtocolFunctions {
	/// Type alias for events
	public typealias EventContextToVoid = ((Context<M,C>) -> Void)
	public typealias EventContextToSize = ((Context<M,C>) -> CGSize)
	public typealias EventContextToBool = ((Context<M,C>) -> Bool)

	public var modelType: Any.Type = M.self
	public var cellType: Any.Type = C.self
	
	public var registerAsClass: Bool {
		return C.registerAsClass
	}

	public var cellReuseIdentifier: String {
		return C.reuseIdentifier
	}
	
	public var cellClass: AnyClass {
		return C.self
	}
	
	/// Registered events for table
	internal var events = [CollectionAdapterEventKey: CollectionAdapterEventable]()

	/// Initialize a new adapter and allows its configuration via builder callback.
	///
	/// - Parameter configuration: configuration callback
	init(_ configuration: ((CollectionAdapter) -> (Void))? = nil) {
		configuration?(self)
	}
	
	/// Register a new event for table.
	///
	/// - Parameter event: event to register.
	/// - Returns: self instance to optionally chain another call.
	@discardableResult
	public func on(_ event: CollectionAdapter.Event<M,C>) -> Self {
		self.events[event.name] = event
		return self
	}
	
	//MARK: Standard Protocol Implementations
	
	/// Description of the adapter
	public var description: String {
		return "Adapter<\(String(describing: self.cellType)),\(String(describing: self.modelType))>"
	}
	
	/// Equatable support.
	/// Two adapters are equal if it manages the same pair of data.
	public static func == (lhs: CollectionAdapter, rhs: CollectionAdapter) -> Bool {
		return 	(String(describing: lhs.modelType) == String(describing: rhs.modelType)) &&
				(String(describing: lhs.cellType) == String(describing: rhs.cellType))
	}
	
	func _invoke(event: CollectionAdapterEventKey, _ models: [ModelProtocol], _ paths: [IndexPath], _ collection: UICollectionView, _ data: [EventArgument : Any?]?) -> Any? {
		switch event {
		case .prefetch:
			guard case .prefetch(let c)? = self.events[.prefetch] as? Event<M,C> else { return nil }
			c(models as! [M],paths,collection)
		case .cancelPrefetch:
			guard case .cancelPrefetch(let c)? = self.events[.cancelPrefetch] as? Event<M,C> else { return nil }
			c(models as! [M],paths,collection)
		default:
			break
		}
		return nil
	}
	
	func _invoke(event: CollectionAdapterEventKey, _ cell: CellProtocol?, _ path: IndexPath, _ collection: UICollectionView, _ data: [EventArgument : Any?]?) {
		switch event {
		case .endDisplay:
			guard case .endDisplay(let c)? = self.events[.endDisplay] as? Event<M,C> else { return }
			c( (cell as! C),path)
		default:
			break
		}
	}
	
	func _invoke(event: CollectionAdapterEventKey, _ model: ModelProtocol, _ cell: CellProtocol?, _ path: IndexPath, _ collection: UICollectionView, _ data: [EventArgument : Any?]?) -> Any? {
		
		guard let _ = self.events[event] else { return nil }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		
		switch event {
		case .dequeue:
			guard case .dequeue(let c)? = self.events[.dequeue] as? Event<M,C> else { return nil }
			c(ctx)
		case .shouldSelect:
			guard case .shouldSelect(let c)? = self.events[.shouldSelect] as? Event<M,C> else { return nil }
			return c(ctx)
		case .shouldDeselect:
			guard case .shouldDeselect(let c)? = self.events[.shouldDeselect] as? Event<M,C> else { return nil }
			return c(ctx)
		case .didSelect:
			guard case .didSelect(let c)? = self.events[.didSelect] as? Event<M,C> else { return nil }
			c(ctx)
		case .didDeselect:
			guard case .didDeselect(let c)? = self.events[.didDeselect] as? Event<M,C> else { return nil }
			c(ctx)
		case .shouldHighlight:
			guard case .shouldHighlight(let c)? = self.events[.shouldHighlight] as? Event<M,C> else { return nil }
			return c(ctx)
		case .willDisplay:
			guard case .willDisplay(let c)? = self.events[.willDisplay] as? Event<M,C> else { return nil }
			c(ctx)
		case .endDisplay:
			guard case .endDisplay(let c)? = self.events[.endDisplay] as? Event<M,C> else { return nil }
			c( (cell as! C), path)
		case .shouldShowEditMenu:
			guard case .shouldShowEditMenu(let c)? = self.events[.shouldShowEditMenu] as? Event<M,C> else { return nil }
			return c(ctx)
		case .performEditAction:
			guard case .performEditAction(let c)? = self.events[.performEditAction] as? Event<M,C> else { return nil }
			c(ctx, (data![.param1] as! Selector), data![.param2])
		case .canPerformEditAction:
			guard case .canPerformEditAction(let c)? = self.events[.canPerformEditAction] as? Event<M,C> else { return nil }
			return c(ctx)
		case .canFocus:
			guard case .canFocus(let c)? = self.events[.canFocus] as? Event<M,C> else { return nil }
			return c(ctx)
		case .itemSize:
			guard case .itemSize(let c)? = self.events[.itemSize] as? Event<M,C> else { return nil }
			return c(ctx)
		case .generateDragPreview:
			guard case .generateDragPreview(let c)? = self.events[.generateDragPreview] as? Event<M,C> else { return nil }
			return c(ctx)
		case .generateDropPreview:
			guard case .generateDropPreview(let c)? = self.events[.generateDropPreview] as? Event<M,C> else { return nil }
			return c(ctx)
		case .didHighlight:
			guard case .didHighlight(let c)? = self.events[.didHighlight] as? Event<M,C> else { return nil }
			c(ctx)
		case .didUnhighlight:
			guard case .didUnhighlight(let c)? = self.events[.didUnhighlight] as? Event<M,C> else { return nil }
			c(ctx)
		case .shouldSpringLoad:
			guard case .shouldSpringLoad(let c)? = self.events[.shouldSpringLoad] as? Event<M,C> else { return nil }
			return c(ctx)
		default:
			break
		}
		
		return nil
	}
	
	// MARK: Internal Protocol Methods
	
	func _instanceCell(in collection: UICollectionView, at indexPath: IndexPath?) -> UICollectionViewCell {
		guard let indexPath = indexPath else {
			let castedCell = self.cellClass as! UICollectionViewCell.Type
			let cellInstance = castedCell.init()
			return cellInstance
		}
		return collection.dequeueReusableCell(withReuseIdentifier: C.reuseIdentifier, for: indexPath)
	}
	
}

public extension CollectionAdapter {
	
	/// Context of the adapter.
	public struct Context<M,C> {
		
		/// Index path of represented context's cell instance
		public let indexPath: IndexPath

		/// Represented model instance
		public let model: M

		/// Managed source collection
		public private(set) weak var collection: UICollectionView?

		/// Managed source collection's bounds size
		public var collectionSize: CGSize? {
			guard let c = collection else { return nil }
			return c.bounds.size
		}
		
		/// Internal cell representation. For some events it may be nil.
		/// You can use public's `cell` property to attempt to get a valid instance of the cell
		/// (if source events allows it).
		private let _cell: C?
		
		/// Represented cell instance.
		/// Depending from the source event where the context is generated it maybe nil.
		/// When not `nil` it's stricly typed to its parent adapter cell's definition.
		public var cell: C? {
			guard let c = _cell else {
				return collection?.cellForItem(at: self.indexPath) as? C
			}
			return c
		}
		
		/// Initialize a new context from a source event.
		/// Instances of the Context are generated automatically and received from events; you don't need to allocate on your own.
		///
		/// - Parameters:
		///   - model: source generic model
		///   - cell: source generic cell
		///   - path: cell's path
		///   - collection: parent cell's collection instance
		internal init(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, collection: UICollectionView) {
			self.model = model as! M
			self._cell = cell as? C
			self.indexPath = path
			self.collection = collection
		}
	}
	
}
