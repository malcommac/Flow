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


internal enum TableAdapterEventsKey: Int {
	case dequeue = 0
	case canEdit
	case commitEdit
	case canMoveRow
	case moveRow
	case prefetch
	case cancelPrefetch
	case rowHeight
	case rowHeightEstimated
	case indentLevel
	case willDisplay
	case shouldSpringLoad
	case editActions
	case tapOnAccessory
	case willSelect
	case didSelect
	case willDeselect
	case didDeselect
	case willBeginEdit
	case didEndEdit
	case editStyle
	case deleteConfirmTitle
	case editShouldIndent
	case moveAdjustDestination
	case endDisplay
	case shouldShowMenu
	case canPerformMenuAction
	case performMenuAction
	case shouldHighlight
	case didHighlight
	case didUnhighlight
	case canFocus
	case leadingSwipeActions
	case trailingSwipeActions
}

internal struct InternalContext {
	var model: ModelProtocol?
	var models: [ModelProtocol]?
	var path: IndexPath?
	var paths: [IndexPath]?
	var cell: CellProtocol?
	var container: Any
	var param1: Any?
	var param2: Any?
	
	public init(_ model: ModelProtocol?, _ path: IndexPath, _ cell: CellProtocol?, _ scrollview: UIScrollView, param1: Any? = nil, param2: Any? = nil) {
		self.model = model
		self.path = path
		self.cell = cell
		self.container = scrollview
		self.param1 = param1
		self.param2 = param2
	}
	
	public init(_ models: [ModelProtocol], _ paths: [IndexPath], _ scrollview: UIScrollView) {
		self.models = models
		self.paths = paths
		self.container = scrollview
	}
}

public enum TableSelectionState {
	case none
	case deselect
	case deselectAnimated
}

// MARK: - TableSection Events
public extension TableSection {
	
	public struct Events {
		public var headerHeigth: (() -> CGFloat)? = nil
		public var footerHeight: (() -> CGFloat)? = nil
		public var estimatedHeaderHeight: (() -> CGFloat)? = nil
		public var estimatedFooterHeight: (() -> CGFloat)? = nil
		public var willDisplayHeader: ((UIView) -> Void)? = nil
		public var willDisplayFooter: ((UIView) -> Void)? = nil
		public var didEndDisplayHeader: ((UIView) -> Void)? = nil
		public var didEndDisplayFooter: ((UIView) -> Void)? = nil
		
		public init() {}
	}
	
}

// MARK: - TableAdapter Events
public extension TableAdapter {
	
	public struct Events<M,C> {
		public typealias EventContext = Context<M,C>
		
		public var dequeue : ((EventContext) -> (Void))? = nil
		
		public var canEdit: ((EventContext) -> Bool)? = nil
		public var commitEdit: ((_ ctx: EventContext, _ commit: UITableViewCellEditingStyle) -> Void)? = nil
		
		public var canMoveRow: ((EventContext) -> Bool)? = nil
		public var moveRow: ((_ ctx: EventContext, _ dest: IndexPath) -> Void)? = nil
		
		public var prefetch: ((_ models: [M], _ paths: [IndexPath]) -> Void)? = nil
		public var cancelPrefetch: ((_ models: [M], _ paths: [IndexPath]) -> Void)? = nil
		
		public var rowHeight: ((EventContext) -> CGFloat)? = nil
		public var rowHeightEstimated: ((EventContext) -> CGFloat)? = nil
		
		public var indentLevel: ((EventContext) -> Int)? = nil
		public var willDisplay: ((EventContext) -> Void)? = nil
		public var shouldSpringLoad: ((EventContext) -> Bool)? = nil
		
		public var editActions: ((EventContext) -> [UITableViewRowAction]?)? = nil
		public var tapOnAccessory: ((EventContext) -> Void)? = nil
		
		public var willSelect: ((EventContext) -> IndexPath?)? = nil
		public var didSelect: ((EventContext) -> TableSelectionState)? = nil
		public var willDeselect: ((EventContext) -> IndexPath?)? = nil
		public var didDeselect: ((EventContext) -> IndexPath?)? = nil
		
		public var willBeginEdit: ((EventContext) -> Void)? = nil
		public var didEndEdit: ((EventContext) -> Void)? = nil
		public var editStyle: ((EventContext) -> UITableViewCellEditingStyle)? = nil
		public var deleteConfirmTitle: ((EventContext) -> String?)? = nil
		public var editShouldIndent: ((EventContext) -> Bool)? = nil
		
		public var moveAdjustDestination: ((_ ctx: EventContext, _ proposed: IndexPath) -> IndexPath?)? = nil
		
		public var endDisplay: ((_ cell: C, _ path: IndexPath) -> Void)? = nil
		
		public var shouldShowMenu: ((EventContext) -> Bool)? = nil
		public var canPerformMenuAction: ((_ ctx: EventContext, _ sel: Selector, _ sender: Any?) -> Bool)? = nil
		public var performMenuAction: ((_ ctx: EventContext, _ sel: Selector, _ sender: Any?) -> Void)? = nil
		
		public var shouldHighlight: ((EventContext) -> Bool)? = nil
		public var didHighlight: ((EventContext) -> Void)? = nil
		public var didUnhighlight: ((EventContext) -> Void)? = nil
		
		public var canFocus: ((EventContext) -> Bool)? = nil
		
		public var leadingSwipeActions: ((EventContext) -> UISwipeActionsConfiguration?)? = nil
		public var trailingSwipeActions: ((EventContext) -> UISwipeActionsConfiguration?)? = nil
	}
	
}
