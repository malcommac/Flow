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

public extension CollectionDirector {
	
	public final class DragAndDropManager: NSObject, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
		
		/// Context of Drag/Drop operation
		public struct Context {
			
			/// Involved index path
			public let indexPath: IndexPath
			
			/// Parent collection
			public private(set) weak var collection: UICollectionView?
			
			/// Involved item instance
			public private(set) var item: ModelProtocol
			
			/// Initialize a new context (private)
			internal init(item: ModelProtocol, at path: IndexPath, of collection: UICollectionView) {
				self.indexPath = path
				self.collection = collection
				self.item = item
			}
		}
		
		//MARK: DRAG EVENTS: PROVIDING ITEMS TO DRAG
		
		/// Managed collection manager
		public internal(set) weak var manager: CollectionDirector?
		
		/// Provides the initial set of items (if any) to drag.
		///
		/// You must implement this method to allow the dragging of items from your collection view.
		/// In your implementation, create one or more UIDragItem objects for the item at the specified indexPath.
		/// Normally, you return only one drag item, but if the specified item has children or cannot be dragged
		/// without one or more associated items, include those items as well.
		///
		/// The collection view calls this method one or more times when a new drag begins within its bounds.
		/// Specifically, if the user begins the drag from a selected item, the collection view calls this method
		/// once for each item that is part of the selection. If the user begins the drag from an unselected item,
		/// the collection view calls the method only once for that item.
		///
		/// An array of UIDragItem objects containing the details of the items to drag.
		/// Return an empty array to prevent the item from being dragged.
		///
		/// NOTE: If not implemented, the default behaviour return an empty set.
		public var onPrepareItemForDrag: ((DragAndDropManager.Context) -> [UIDragItem])? = nil
		
		/// Adds the specified items to an existing drag session.
		///
		/// Implement this method when you want to allow the user to add items to an active drag session.
		/// If you do not implement this method, taps in the collection view trigger the selection of items or other behaviors.
		/// However, when a drag session is active and a tap occurs, the collection view calls this method to give you
		/// an opportunity to add the underlying item to the drag session.
		///
		/// In your implementation, create one or more UIDragItem objects for the item at the specified indexPath.
		/// Normally, you return only one drag item, but if the specified item has children or cannot be dragged
		/// without one or more associated items, include those items as well.
		///
		/// It must return an array of UIDragItem objects containing the items to add to the current drag session.
		/// Return an empty array to prevent the items from being added to the drag session.
		///
		/// NOTE: If not implemented, the default behaviour return an empty set.
		public var onAddItemToDragSession: ((DragAndDropManager.Context) -> [UIDragItem])? = nil
		
		//MARK: DRAG EVENTS: TRACKING THE DRAG SESSION
		
		/// Called to let you know that a drag session is about to begin for the collection view.
		public var onWillBeginDragSession: ((UIDragSession) -> Void)? = nil
		
		/// This method is called after the drag session ended, usually because the content was dropped
		/// but possibly because the drag was aborted.
		/// Use this method to close out any tasks related to the management of the drag session in your app.
		///
		/// Each call to this method is always balanced by a call to the `onWillBeginDragSession` event.
		public var onDidEndDragSession: ((UIDragSession) -> Void)? = nil
		
		/// Restrict drag session to the app only
		/// If not implemented it return `true`.
		public var onDragSessionRestrictedToApp: ((UIDragSession) -> Bool)? = nil
		
		/// Allows move operation for given drag session
		/// If not implemented it return `true`.
		public var onDragSessionAllowsMoveOperation: ((UIDragSession) -> Bool)? = nil
		
		//MARK: DROP EVENTS: DECLARING SUPPORT TO DROP
		
		/// Asks whether the collection view can accept a drop with the specified type of data.
		///
		/// Implement this method when you want to dynamically determine whether to accept dropped data in your collection view.
		/// In your implementation, check the type of the dragged data and return a Boolean value indicating whether you can
		/// accept the drop.
		///
		/// For example, you might call the hasItemsConforming(toTypeIdentifier:) method of the session object
		/// to determine whether it contains data that your app can accept.
		///
		/// If you do not implement this method, the collection view assumes a return value of true.
		/// If you return false from this method, the collection view does not call any more methods of
		/// your drop delegate for the given session.
		public var onAcceptDropDession: ((UIDropSession) -> Bool)? = nil
		
		//MARK: DROP EVENTS: INCORPORATING DROPPED DATA
		
		/// Tells to incorporate the drop data into the collection view.
		/// Use this method to accept the dropped content and integrate it into your collection view.
		/// In your implementation, iterate over the items property of the coordinator object and fetch
		/// the data from each UIDragItem.
		///
		/// Incorporate the data into your collection view's data source and update the collection view itself
		/// by inserting any needed items.
		/// When incorporating items, use the methods of the coordinator object to animate the transition
		/// from the drag item's preview to the corresponding item in your collection view. For items that you incorporate
		/// immediately, you can use the drop(_:to:) or drop(_:toItemAt:) method to perform the animation.
		/// When loading content asynchronously from an NSItemProvider, you can animate the drop to a placeholder
		/// cell using the drop(_:toPlaceholderInsertedAt:withReuseIdentifier:cellUpdateHandler:) method.
		public var onPerformDrop: ((UICollectionViewDropCoordinator) -> Void)? = nil
		
		//MARK: DROP EVENTS: TRACKING DROP MOVEMENTS
		
		/// Tells that the position of the dragged data over the collection view changed.
		///
		/// While the user is dragging content, the collection view calls this method repeatedly to
		/// determine how you would handle the drop if it occurred at the specified location.
		/// The collection view provides visual feedback to the user based on your proposal.
		///
		/// You must implement this method to support drop; nil implementation raise a fatalError.
		public var onDropSessionDidUpdate: ((_ session: UIDropSession, _ path: IndexPath?) -> UICollectionViewDropProposal)? = nil
		
		/// Called when dragged content enters the collection view's bounds rectangle.
		/// The collection view calls this method when dragged content enters its bounds rectangle.
		/// The method is not called again until the dragged content exits the collection view's bounds
		/// (triggering a call to the `onDropSessionDidExit` method) and enters again.
		///
		/// Use this method to perform any one-time setup associated with tracking dragged content over the collection view.
		public var onDropSessionDidEnter:  ((_ session: UIDropSession) -> Void)? = nil
		
		/// Called when dragged content exits the table view's bounds rectangle.
		/// UIKit calls this method when dragged content exits the bounds rectangle of the specified collection view.
		/// The method is not called again until the dragged content enters the collection view's bounds
		/// (triggering a call to the `onDropSessionDidEnter` method) and exits again.
		///
		/// Use this method to clean up any state information that you configured in your `onDropSessionDidEnter`.
		public var onDropSessionDidExit:  ((_ session: UIDropSession) -> Void)? = nil
		
		/// Called to notify you when the drag operation ends.
		/// The collection view calls this method at the conclusion of a drag that was over the collection view at one point.
		/// Use it to clean up any state information that you used to handle the drag.
		/// This method is called regardless of whether the data was actually dropped onto the collection view.
		public var onDropSessionDidEnd:  ((_ session: UIDropSession) -> Void)? = nil
		
		//MARK: INIT
		
		/// Internal init
		internal init(manager: CollectionDirector) {
			super.init()
			self.manager = manager
		}
		
		//MARK: UICollectionViewDragDelegate EVENTS
		
		public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
			guard let event = self.onPrepareItemForDrag else {
				return []
			}
			let ctx = Context(item: self.manager!.item(at: indexPath, safe: false)!, at: indexPath, of: collectionView)
			return event(ctx)
		}
		
		public func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
			guard let event = self.onAddItemToDragSession else {
				return []
			}
			let ctx = Context(item: self.manager!.item(at: indexPath, safe: false)!, at: indexPath, of: collectionView)
			return event(ctx)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
			guard let event = self.onWillBeginDragSession else { return }
			event(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
			guard let event = self.onDidEndDragSession else { return }
			event(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
			let (model,adapter) = self.manager!.context(forItemAt: indexPath)
			return (adapter.dispatch(.generateDragPreview, context: InternalContext(model, indexPath, nil, collectionView)) as? UIDragPreviewParameters)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
			guard let event = self.onDragSessionRestrictedToApp else { return true }
			return event(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
			guard let event = self.onDragSessionAllowsMoveOperation else { return true }
			return event(session)
		}
		
		//MARK: Drop Events Manager
		
		public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
			self.onPerformDrop?(coordinator)
		}
		
		public func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
			guard let event = self.onAcceptDropDession else { return true }
			return event(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dropSessionDidEnter session: UIDropSession) {
			self.onDropSessionDidEnter?(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
			self.onDropSessionDidExit?(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
			self.onDropSessionDidEnd?(session)
		}
		
		public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
			guard let event = self.onDropSessionDidUpdate else {
				fatalError("Missing CollectionManager Drag&Drop Implementation of onDropSessionDidUpdate event")
			}
			return event(session,destinationIndexPath)
		}
		
	}
	
}
