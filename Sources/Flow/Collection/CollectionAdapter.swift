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
	
	public var on = CollectionAdapter.Events<M,C>()

	/// Initialize a new adapter and allows its configuration via builder callback.
	///
	/// - Parameter configuration: configuration callback
	init(_ configuration: ((CollectionAdapter) -> (Void))? = nil) {
		configuration?(self)
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
	
	func dispatch(_ event: CollectionAdapterEventKey, context: InternalContext) -> Any? {
		switch event {
			
		case .dequeue:
			guard let callback = self.on.dequeue else { return nil }
			callback(Context<M,C>(generic: context))
			
		case .shouldSelect:
			guard let callback = self.on.shouldSelect else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .didSelect:
			guard let callback = self.on.didSelect else { return nil }
			callback(Context<M,C>(generic: context))
			
		case .didDeselect:
			guard let callback = self.on.didDeselect else { return nil }
			callback(Context<M,C>(generic: context))
			
		case .didHighlight:
			guard let callback = self.on.didHighlight else { return nil }
			callback(Context<M,C>(generic: context))
			
		case .didUnhighlight:
			guard let callback = self.on.didUnhighlight else { return nil }
			callback(Context<M,C>(generic: context))
			
		case .shouldHighlight:
			guard let callback = self.on.shouldHighlight else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .willDisplay:
			guard let callback = self.on.willDisplay else { return nil }
			callback((context.cell as! C), context.path!)
			
		case .endDisplay:
			guard let callback = self.on.endDisplay else { return nil }
			callback((context.cell as! C), context.path!)
			
		case .shouldShowEditMenu:
			guard let callback = self.on.shouldShowEditMenu else { return nil }
			return callback(Context<M,C>(generic: context))

		case .canPerformEditAction:
			guard let callback = self.on.canPerformEditAction else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .performEditAction:
			guard let callback = self.on.performEditAction else { return nil }
			return callback(Context<M,C>(generic: context), (context.param1 as! Selector), context.param2)
			
		case .canFocus:
			guard let callback = self.on.canFocus else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .itemSize:
			guard let callback = self.on.itemSize else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .generateDragPreview:
			guard let callback = self.on.generateDragPreview else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .generateDropPreview:
			guard let callback = self.on.generateDropPreview else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .prefetch:
			guard let callback = self.on.prefetch else { return nil }
			callback((context.models as! [M]), context.paths!, (context.container as! UICollectionView))
			
		case .cancelPrefetch:
			guard let callback = self.on.cancelPrefetch else { return nil }
			callback((context.models as! [M]), context.paths!, (context.container as! UICollectionView))
			
		case .shouldSpringLoad:
			guard let callback = self.on.shouldSpringLoad else { return nil }
			return callback(Context<M,C>(generic: context))
			
		case .shouldDeselect:
			guard let callback = self.on.shouldDeselect else { return nil }
			return callback(Context<M,C>(generic: context))
			
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
		
		internal init(generic: InternalContext) {
			self.model = (generic.model as! M)
			self._cell = (generic.cell as? C)
			self.indexPath = generic.path!
			self.collection = (generic.container as! UICollectionView)
		}
	}
	
}
