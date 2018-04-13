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

	//MARK: Public Events
	
	/// This event is called when cell is ready to be configured with the model instance received.
	/// It's the old `dequeueReusableCell` event of your collection datasource implementation.
	public var onConfigure: EventContextToVoid? = nil
	
	/// The collection view calls this method when the user tries to select an item in the collection view.
	/// It does not call this method when you programmatically set the selection.
	///
	/// If you do not implement this method, the default return value is `true`.
	public var onShouldSelect: EventContextToBool? = nil
	
	/// The collection view calls this method when the user tries to deselect an item in the collection view.
	/// It does not call this method when you programmatically deselect items.
	///
	/// If you do not implement this method, the default return value is `true`.
	public var onShouldDeselect: EventContextToBool? = nil

	/// The collection view calls this method when the user successfully selects an item in the collection view.
	/// It does not call this method when you programmatically set the selection.
	public var onDidSelect: EventContextToVoid? = nil
	
	/// The collection view calls this method when the user successfully deselects an item in the collection view.
	/// It does not call this method when you programmatically deselect items.
	public var onDidDeselect: EventContextToVoid? = nil
	
	/// As touch events arrive, the collection view highlights items in anticipation of the user selecting them.
	/// As it processes those touch events, the collection view calls this method to ask your delegate if a given
	/// cell should be highlighted.
	/// It calls this method only in response to user interactions and does not call it if you programmatically set the highlighting on a cell.
	///
	/// If you do not implement this method, the default return value is true.
	public var onShouldHighlight: EventContextToBool? = nil

	/// Tells that the item at the specified index path was highlighted.
	public var onDidHighlight: EventContextToVoid? = nil
	
	/// Tells that the highlight was removed from the item at the specified index path.
	public var onDidUnhighlight: EventContextToVoid? = nil
	
	/// Tells that the specified cell is about to be displayed in the collection view.
	public var onWillDisplay: EventContextToVoid? = nil

	/// Tells that the specified cell was removed from the collection view.
	public var onEndDisplay: ((_ cell: C, _ path: IndexPath) -> (Void))? = nil
	
	//MARK: Managing Actions for Cells
	
	/// Asks the delegate if an action menu should be displayed for the specified item.
	/// If the user tap-holds a certain item in the collection view, this method (if implemented) is invoked first.
	/// Return `true` if you want to permit the editing menu to be displayed.
	/// Return `false` if the editing menu shouldn’t be shown—for example, you might return false if the corresponding item contains data that should not be copied or pasted over.
	///
	/// If you do not implement this method, the default return value is `false`.
	public var onShouldShowEditMenu: EventContextToBool? = nil
	
	/// Asks the delegate if it can perform the specified action on an item in the collection view.
	/// This method is invoked after the `onShouldShowEditMenu` method.
	/// It gives you the opportunity to exclude commands from the editing menu.
	/// For example, the user might have copied some content from one item and wants to paste it into another item that cannot accept the content.
	/// In such a case, your method could return false to prevent the display of the relevant command.
	///
	/// If you do not implement this method, the default return value is `false`.
	public var onCanPerformEditAction: ((_ context: Context<M,C>, _ selector: Selector, _ sender: Any?) -> Bool)? = nil
	
	/// Tells to perform the specified action on an item in the collection view.
	/// If the user taps an action in the editing menu, the collection view calls this method.
	/// Your implementation of this method should do whatever is appropriate for the action.
	/// For example, for a copy action, it should extract the relevant item content and write it to the general pasteboard or an application (private) pasteboard.
	/// For information about how to perform pasteboard-related operations, see UIPasteboard.
	public var onPerformEditAction: ((_ context: Context<M,C>, _ selector: Selector, _ sender: Any?) -> Void)? = nil
	
	/// Asks whether the item at the specified index path can be focused.
	/// You can use this method, or a cell’s canBecomeFocused method, to control which items in the collection view can receive focus.
	/// The focus engine calls the cell’s canBecomeFocused method first, the default implementation of which defers to the collection view and this delegate method.
	/// If you do not implement this method, the ability to focus on items depends on whether the collection view’s items are selectable.
	/// When the items are selectable, they can also be focused as if this method had returned true; otherwise, they do not receive focus.
	public var onCanFocusItem: EventContextToBool? = nil
	
	/// Returns a Boolean value indicating whether you want the spring-loading interaction effect displayed for the specified item.
	/// If you do not implement this method, the collection view assumes a return value of `true`.
	public var onShouldSpringLoadItem: EventContextToBool? = nil

	/// Asks  for the size of the specified item’s cell (it works only in UICollectionView with flow layout).
	public var onGetItemSize: EventContextToSize? = nil
	
	/// Use this method to customize the appearance of the item during drags.
	/// If you do not implement this method or if you implement it and return nil,
	/// the collection view uses the cell's visible bounds to create the preview.
	///
	/// You must activate the drag&drop via `dragDropEnabled` property in collection manager and set the appropriate
	/// implementation `dragDrop` manager.
	public var onGenerateDragPreview: ((_ context: Context<M,C>) -> UIDragPreviewParameters?)? = nil
	
	/// Use this method to customize the appearance of the item during drop.
	///
	/// You must activate the drag&drop via `dragDropEnabled` property in collection manager and set the appropriate
	/// implementation `dragDrop` manager.
	public var onGenerateDropPreview: ((_ context: Context<M,C>) -> UIDragPreviewParameters?)? = nil
	
	/// Instructs your prefetch data source object to begin preparing data for the cells at the supplied index paths.
	/// Models and Paths arrays are synced (nth model instance in `items` is located at nth position of `paths`).
	///
	/// The collection view calls this method as the user scrolls, providing the index paths for cells it is likely to display in the near future.
	/// Your implementation of this method is responsible for starting any expensive data loading processes.
	/// The data loading must be performed asynchronously, and the results made available to the `onConfigure` method.
	///
	/// The collection view does not call this method for cells it requires immediately, so your code must not rely on this method to load data.
	/// The order of the index paths provided represents the priority.
	///
	/// NOTE: This event is called only if `prefetchEnabled` of the parent manager is enabled.
	public var onRequestPrefetchFor: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> (Void))? = nil
	
	/// Cancels a previously triggered data prefetch request.
	/// Models and Paths arrays are synced (nth model instance in `items` is located at nth position of `paths`).
	///
	/// The collection view calls this method to cancel prefetch requests as cells scroll out of view.
	/// Your implementation of this method is responsible for canceling the operations initiated by a previous call to `onRequestPrefetchFor`.
	///
	/// NOTE: This event is called only if `prefetchEnabled` of the parent manager is enabled.
	public var onCancelPrefetchFor: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> (Void))? = nil
	
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
	
	// MARK: Internal Protocol Methods
	
	func _instanceCell(in collection: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		return collection.dequeueReusableCell(withReuseIdentifier: C.reuseIdentifier, for: indexPath)
	}
	
	func _onDequeue(model: ModelProtocol, cell: CellProtocol, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onConfigure else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}
	
	func _itemSize(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> CGSize {
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		guard let size = self.onGetItemSize?(ctx) else {
			fatalError("Missing itemSize implementation for: \(self)")
		}
		return size
	}
	
	func _willDisplay(model: ModelProtocol, cell: CellProtocol, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onWillDisplay else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}
	
	func _didEndDisplay(cell: CellProtocol, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onEndDisplay, let c = cell as? C else { return }
		event(c,path)
	}
	
	func _didSelect(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onDidSelect else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}

	func _didDeselect(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onDidDeselect else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}
	
	func _didHighlight(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onDidHighlight else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}
	
	func _didUnHighlight(model: ModelProtocol, cell: CellProtocol?, path: IndexPath, collection: UICollectionView) {
		guard let event = self.onDidUnhighlight else { return }
		let ctx = Context<M,C>(model: model, cell: cell, path: path, collection: collection)
		event(ctx)
	}

	func _shouldSelect(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onShouldSelect else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _shouldDeSelect(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onShouldDeselect else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}

	func _shouldHighlight(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onShouldHighlight else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _shouldShowEditMenu(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onShouldHighlight else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _canPerformEditMenuAction(model: ModelProtocol, path: IndexPath, collection: UICollectionView, selector: Selector, sender: Any?) -> Bool {
		guard let event = self.onCanPerformEditAction else { return false }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx,selector,sender)
	}
	
	func _performEditMenuAction(model: ModelProtocol, path: IndexPath, collection: UICollectionView, selector: Selector, sender: Any?) -> Void {
		guard let event = self.onPerformEditAction else { return }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx,selector,sender)
	}
	
	func _canFocusItem(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onCanFocusItem else { return (collection.allowsSelection || collection.allowsMultipleSelection) }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _shouldSpringLoadItem(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> Bool {
		guard let event = self.onShouldSpringLoadItem else { return true }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _generateDragPreview(model: ModelProtocol, path: IndexPath, collection: UICollectionView) -> UIDragPreviewParameters? {
		guard let event = self.onGenerateDragPreview else { return nil }
		let ctx = Context<M,C>(model: model, cell: nil, path: path, collection: collection)
		return event(ctx)
	}
	
	func _didPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], collection: UICollectionView) {
		guard let event = self.onRequestPrefetchFor else { return }
		return event(models as! [M],indexPaths,collection)
	}
	
	func _didCancelPrefetchItems(models: [ModelProtocol], indexPaths: [IndexPath], collection: UICollectionView) {
		guard let event = self.onCancelPrefetchFor else { return }
		return event(models as! [M],indexPaths,collection)
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
