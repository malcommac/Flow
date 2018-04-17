//
//  TableEvent.swift
//  Flow
//
//  Created by Daniele Margutti on 18/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public protocol Eventable {
	var name: TableEventName { get }
}

public enum EventArgument: String, Hashable {
	case param1
	case param2
}

public enum TableEventName: String {
	case dequeue
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
	case shouldHighlight
	case didHighlight
	case didUnhighlight
	case canFocus
	case performMenuAction
	case leadingSwipeActions
	case trailingSwipeActions
}

public extension TableAdapter {
	
	public enum Event<M,C>: Eventable {
		// Configuring a Table View
		case dequeue(_: ((_ ctx: Context<M,C>) -> Void))
		
		// Inserting or Deleting Table Rows
		case canEdit(_: ((_ ctx: Context<M,C>) -> Bool))
		case commitEdit(_: ((_ ctx: Context<M,C>, _ commit: UITableViewCellEditingStyle) -> Void))
		
		// Reordering Table Rows
		case canMoveRow(_: ((_ ctx: Context<M,C>) -> Bool))
		case moveRow(_: ((_ ctx: Context<M,C>, _ dest: IndexPath) -> Void))
		
		// Prefetching data
		case prefetch(_: ((_ models: [M], _ paths: [IndexPath]) -> Void))
		case cancelPrefetch(_: ((_ models: [M], _ paths: [IndexPath]) -> Void))
		
		// Configuring Rows for the Table View
		case rowHeight(_: ((_ ctx: Context<M,C>) -> CGFloat))
		case rowHeightEstimated(_: ((_ ctx: Context<M,C>) -> CGFloat))
		case indentLevel(_: ((_ ctx: Context<M,C>) -> Int))
		case willDisplay(_: ((_ ctx: Context<M,C>) -> Void))
		case shouldSpringLoad(_: ((_ ctx: Context<M,C>) -> Bool))
		
		// Managing Accessory View
		case editActions(_: ((_ ctx: Context<M,C>) -> [UITableViewRowAction]?))
		case tapOnAccessory(_: ((_ ctx: Context<M,C>) -> Void))
		
		// Managing Selections
		case willSelect(_: ((_ ctx: Context<M,C>) -> IndexPath?))
		case didSelect(_: ((_ ctx: Context<M,C>) -> Void))
		case willDeselect(_: ((_ ctx: Context<M,C>) -> IndexPath?))
		case didDeselect(_: ((_ ctx: Context<M,C>) -> Void))
		
		// Editing Table Rows
		case willBeginEdit(_: ((_ ctx: Context<M,C>) -> Void))
		case didEndEdit(_: ((_ ctx: Context<M,C>) -> Void))
		case editStyle(_: ((_ ctx: Context<M,C>) -> UITableViewCellEditingStyle))
		case deleteConfirmTitle(_: ((_ ctx: Context<M,C>) -> String?))
		case editShouldIndent(_: ((_ ctx: Context<M,C>) -> Bool))
		
		// Reordering Table Rows
		case moveAdjustDestination(_: ((_ ctx: Context<M,C>, _ proposed: IndexPath) -> IndexPath?))
		
		// Tracking the removal of views
		case endDisplay(_: ((_ cell: C, _ path: IndexPath) -> Void))
		
		// Copying and pasting row content
		case shouldShowMenu(_: ((_ ctx: Context<M,C>) -> Bool))
		case canPerformMenuAction(_: ((_ ctx: Context<M,C>, _ sel: Selector, _ sender: Any?) -> Bool))
		case performMenuAction(_: ((_ ctx: Context<M,C>, _ sel: Selector, _ sender: Any?) -> Void))
		
		// Managing Table View Highlight
		case shouldHighlight(_: ((_ ctx: Context<M,C>) -> Bool))
		case didHighlight(_: ((_ ctx: Context<M,C>) -> Void))
		case didUnhighlight(_: ((_ ctx: Context<M,C>) -> Void))
		
		// Managing Table View Focus
		case canFocus(_: ((_ ctx: Context<M,C>) -> Bool))
		
		// Handling Swipe Actions
		case leadingSwipeActions(_: ((_ ctx: Context<M,C>) -> UISwipeActionsConfiguration?))
		case trailingSwipeActions(_: ((_ ctx: Context<M,C>) -> UISwipeActionsConfiguration?))
		
		public var name: TableEventName {
			switch self {
			case .dequeue:				return .dequeue
			case .canEdit:				return .canEdit
			case .commitEdit:			return .commitEdit
			case .canMoveRow:			return .canMoveRow
			case .moveRow:				return .moveRow
			case .prefetch:				return .prefetch
			case .cancelPrefetch:		return .cancelPrefetch
			case .rowHeight:			return .rowHeight
			case .rowHeightEstimated:	return .rowHeightEstimated
			case .indentLevel:			return .indentLevel
			case .willDisplay:			return .willDisplay
			case .shouldSpringLoad:		return .shouldSpringLoad
			case .editActions:			return .editActions
			case .tapOnAccessory:		return .tapOnAccessory
			case .willSelect:			return .willSelect
			case .willDeselect:			return .willDeselect
			case .willBeginEdit:		return .willBeginEdit
			case .didEndEdit:			return .didEndEdit
			case .editStyle:			return .editStyle
			case .deleteConfirmTitle:	return .deleteConfirmTitle
			case .editShouldIndent:		return .editShouldIndent
			case .moveAdjustDestination:return .moveAdjustDestination
			case .endDisplay:			return .endDisplay
			case .shouldShowMenu:		return .shouldShowMenu
			case .canPerformMenuAction:	return .canPerformMenuAction
			case .shouldHighlight:		return .shouldHighlight
			case .didUnhighlight:		return .didUnhighlight
			case .canFocus:				return .canFocus
			case .leadingSwipeActions:	return .leadingSwipeActions
			case .trailingSwipeActions:	return .trailingSwipeActions
			case .didSelect:			return .didSelect
			case .didDeselect:			return .didDeselect
			case .performMenuAction:	return .performMenuAction
			case .didHighlight:			return .didHighlight
			}
		}
	}
	
}
