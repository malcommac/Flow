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

// MARK: - CollectionAdapter Events
public extension CollectionAdapter {
	
	public struct Events<M,C> {
		public typealias EventContext = Context<M,C>
		
		var dequeue: ((EventContext) -> Void)? = nil
		var shouldSelect: ((EventContext) -> Bool)? = nil
		var shouldDeselect: ((EventContext) -> Bool)? = nil
		var didSelect: ((EventContext) -> Void)? = nil
		var didDeselect: ((EventContext) -> Void)? = nil
		var didHighlight: ((EventContext) -> Void)? = nil
		var didUnhighlight: ((EventContext) -> Void)? = nil
		var shouldHighlight: ((EventContext) -> Bool)? = nil
		var willDisplay: ((_ cell: C, _ path: IndexPath) -> Void)? = nil
		var endDisplay: ((_ cell: C, _ path: IndexPath) -> Void)? = nil
		var shouldShowEditMenu: ((EventContext) -> Bool)? = nil
		var canPerformEditAction: ((EventContext) -> Bool)? = nil
		var performEditAction: ((_ ctx: EventContext, _ selector: Selector, _ sender: Any?) -> Void)? = nil
		var canFocus: ((EventContext) -> Bool)? = nil
		var itemSize: ((EventContext) -> CGSize)? = nil
		var generateDragPreview: ((EventContext) -> UIDragPreviewParameters?)? = nil
		var generateDropPreview: ((EventContext) -> UIDragPreviewParameters?)? = nil
		var prefetch: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> Void)? = nil
		var cancelPrefetch: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> Void)? = nil
		var shouldSpringLoad: ((EventContext) -> Bool)? = nil
	}
	
}

public enum CollectionAdapterEventKey: Int {
	case dequeue
	case shouldSelect
	case shouldDeselect
	case didSelect
	case didDeselect
	case didHighlight
	case didUnhighlight
	case shouldHighlight
	case willDisplay
	case endDisplay
	case shouldShowEditMenu
	case canPerformEditAction
	case performEditAction
	case canFocus
	case itemSize
	case generateDragPreview
	case generateDropPreview
	case prefetch
	case cancelPrefetch
	case shouldSpringLoad
}

// MARK: - CollectionDirector Events
public extension CollectionDirector {
	
	public struct Events {
		var layoutDidChange: ((_ old: UICollectionViewLayout, _ new: UICollectionViewLayout) -> UICollectionViewTransitionLayout?)? = nil
		var targetOffset: ((_ proposedContentOffset: CGPoint) -> CGPoint)? = nil
		var moveItemPath: ((_ originalIndexPath: IndexPath, _ proposedIndexPath: IndexPath) -> IndexPath)? = nil
		var shouldUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext) -> Bool)? = nil
		var didUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator) -> Void)? = nil
	}
	
}
