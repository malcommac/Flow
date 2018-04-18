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

public enum TableSelectionState {
	case none
	case deselect
	case deselectAnimated
}

public extension TableAdapter {
	
	/// Available events for table's adapter.
	///
	/// - dequeue->Void: Used to configure cell's content just after the creation (`tableView(:,cellForRowAt:)`)
	/// - canEdit->Bool: Asks to verify that the given row is editable (`tableView(_:canEditRowAt:)`)
	/// - commitEdit->Void: Asks to commit the insertion or deletion of a specified row in the receiver (`tableView(:,commit:,forRowAt:)`)
	/// - canMoveRow->Bool: Asks whether a given row can be moved to another location in the table view (`tableView(:,canMoveRowAt:)`)
	/// - moveRow->Void: Tells the data source to move a row at a specific location in the table view to another location. (`tableView(:, moveRowAt:,to:`)
	/// - prefetch->Void:
	/// - cancelPrefetch->Void:
	/// - rowHeight->CGFloat: Asks for the height to use for a row in a specified location (`tableView(_:heightForRowAt:)`)
	/// - rowHeightEstimated->CGFloat: Asks for the estimated height of the header of a particular section. (`tableView(_:estimatedHeightForHeaderInSection:)`)
	/// - indentLevel->Int: Asks to return the level of indentation for a row in a given section (`tableView(_:indentationLevelForRowAt:)`)
	/// - willDisplay->Void: Tells the table view is about to draw a cell for a particular row (`tableView(_:willDisplay:forRowAt:)`)
	/// - shouldSpringLoad->Bool: Called to let you fine tune the spring-loading behavior of the rows in a table (`tableView(_:shouldSpringLoadRowAt:with:)`)
	/// - editActions->: Asks for the actions to display in response to a swipe in the specified row (`tableView(_:editActionsForRowAt:)`)
	/// - tapOnAccessory->Void: Tells that the user tapped the accessory (disclosure) view associated with a given row (`tableView(_:accessoryButtonTappedForRowWith:)`)
	/// - willSelect->IndexPath?: Tells that a specified row is about to be selected (`tableView(_:willSelectRowAt:)`)
	/// - didSelect->TableSelectionState: Tells that the specified row is now selected (`tableView(_:didSelectRowAt:)`)
	/// - willDeselect->IndexPath?: Tells that a specified row is about to be deselected (`tableView(_:willDeselectRowAt:)`)
	/// - didDeselect->Void: Tells that the specified row is now deselected (`tableView(_:didDeselectRowAt:)`)
	/// - willBeginEdit->Void: Tells that the table view is about to go into editing mode (`tableView(_:willBeginEditingRowAt:)`)
	/// - didEndEdit->Void: Tells that the table view has left editing mode (`tableView(_:didEndEditingRowAt:)`)
	/// - editStyle->UITableViewCellEditingStyle: Asks for the editing style of a row at a particular location in a table view (`tableView(_:editingStyleForRowAt:)`)
	/// - deleteConfirmTitle->String?: Changes the default title of the delete-confirmation button (`tableView(_:titleForDeleteConfirmationButtonForRowAt:)`)
	/// - editShouldIndent->Bool: Asks whether the background of the specified row should be indented while the table view is in editing mode (`tableView(_:shouldIndentWhileEditingRowAt:)`)
	/// - moveAdjustDestination->IndexPath?: Tells to move a row at a specific location in the table view to another location (`tableView(_:moveRowAt:to:)`)
	/// - endDisplay->Void: Tells that the specified cell was removed from the table (`tableView(_:didEndDisplaying:forRowAt:)`)
	/// - shouldShowMenu->Bool: Asks if an action menu should be displayed for the specified row (`tableView(_:shouldShowMenuForRowAt:)`)
	/// - canPerformMenuAction->Bool: Asks if the editing menu should omit the Copy or Paste command for a given row (`tableView(_:canPerformAction:forRowAt:withSender:)`)
	/// - performMenuAction->Void: Tells to perform a copy or paste operation on the content of a given row (`tableView(_:performAction:forRowAt:withSender:)`)
	/// - shouldHighlight->Bool: Asks if the specified row should be highlighted (`tableView(_:shouldHighlightRowAt:)`)
	/// - didHighlight->Void: Tells that the specified row was highlighted (`tableView(_:didHighlightRowAt:)`)
	/// - didUnhighlight->Void: Tells that the highlight was removed from the row at the specified index path (`tableView(_:didUnhighlightRowAt:)`)
	/// - canFocus->Bool: Asks whether the cell at the specified index path is itself focusable (`tableView(_:canFocusRowAt:)`)
	/// - leadingSwipeActions->UISwipeActionsConfiguration?: Returns the swipe actions to display on the leading edge of the row (`tableView(_:leadingSwipeActionsConfigurationForRowAt:)`)
	/// - trailingSwipeActions->UISwipeActionsConfiguration?: Returns the swipe actions to display on the trailing edge of the row (`tableView(_:trailingSwipeActionsConfigurationForRowAt:)`)
	public enum Event<M,C>: TableEventable {
		
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
		case didSelect(_: ((_ ctx: Context<M,C>) -> TableSelectionState))
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
		
		var name: TableAdapterEventKey {
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

/// Internal Event Register Hooks

internal protocol TableEventable {
	var name: TableAdapterEventKey { get }
}

internal enum EventArgument: String, Hashable {
	case param1
	case param2
}

internal enum TableAdapterEventKey: String {
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
