//
//	Flow
//	A declarative approach to UITableView management
//	------------------------------------------------
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

/// How to manage a cell selection
///
/// - keepSelection: selection still in place, `onSelect` is called sequentially
/// - deselect: deselect automtically on tap (specify if animated or not)
public enum RowTapBehaviour {
	case keepSelection
	case deselect(_: Bool)
}

/// Protocol of the table's row
public protocol RowProtocol {
	
	typealias RowReference = ((RowProtocol) -> (Void))
	
	/// PRIVATE
	
	/// This is for internal purpose only.
	/// Return the valid value of associated `DeclarativeCell`'s `estimatedHeight`.
	var _estimatedHeight: CGFloat? { get }
	
	/// This is for internal purpose only.
	/// Return the valid value of associated `DeclarativeCell`'s `defaultHeight`.
	var _defaultHeight: CGFloat? { get }
	
	/// This is for internal purpose only.
	/// Return the valid value of associated `DeclarativeCell`'s `shouldHighlight`.
	var _shouldHighlight: Bool? { get }
	
	/// Private use only.
	var _indexPath: 		IndexPath? { get set }
	
	/// Instance of the represented cell for this row (set only if row is visible, maybe `nil`)
	var _instance:			UITableViewCell? { get }
	
	/// PUBLIC

	/// Optional unique identifier for this row
	var identifier:			String? { get set }
	
	/// When associated cell is dequeued this value contains the associated
	/// indexPath value.
	var indexPath:			IndexPath? { get }
	
	/// Reuse identifier of the cell
	var reuseIdentifier:	String { get }
	
	/// Type of cell which represent the row
	var cellType:			AnyClass { get }
	
	/// Allows the user to perform an estimation of the height of the cell.
	/// This is done at runtime level when a single instance of the Row is about to be displayed.
	/// You can return a fixed height or `UITableViewAutomaticDimension`.
	/// If you return `nil` the result of the method is ignored and the request is made statically
	/// to the `estimatedHeight` of the provided cell class.
	/// If, even this method, return `nil` `TableManager` attempt to evaluate the height of the cell
	/// by creating it and getting the size of the `contentView`.
	var evaluateEstimatedHeight: (() -> (CGFloat?))? { get set }

	/// Allows the user to return the height of the cell.
	/// This is done at runtime level when a single instance of the Row is about to be displayed.
	/// You can return a fixed height or `UITableViewAutomaticDimension`.
	/// If you return `nil` the result of the method is ignored and the request is made statically
	/// to the `defaultHeight` of the provided cell class.
	/// If, even this method, return `nil` `TableManager` attempt to evaluate the height of the cell
	/// by creating it and getting the size of the `contentView`.
	var evaluateRowHeight: (() -> (CGFloat?))? { get set }
	
	/// Allows the user to configure the cell instance
	///
	/// - Parameters:
	///   - cell: cell instance to configure
	///   - path: destination indexPath of the cell
	func configure(_ cell: UITableViewCell, path: IndexPath)

	/// hash value of the row
	var hashValue: Int { get }

	/// Message received when a cell instance has been made
	//var onDequeue: RowEventCallback? { get set }
	var onDequeue: RowReference? { get set }
	
	/// Message received when user tap on a cell at specified path. You must provide a default behaviour
	/// by returning one of the `RowTapBehaviour` options. If `nil` is provided the default
	/// behaviour is `deselect` with animation.
	//var onTap: ((RowInfo) -> (RowTapBehaviour?))? { get set }
	var onTap: ((RowProtocol) -> (RowTapBehaviour?))? { get set }
	
	/// Message received when a selection has been made. Selection still active only if
	/// `onTap` returned `.keepSelection` option.
	//var onSelect: RowEventCallback? { get set }
	var onSelect: RowReference? { get set }

	/// Message received when cell at specified path did deselected
	//var onDeselect: RowEventCallback? { get set }
	var onDeselect: RowReference? { get set }

	/// Message received when a cell at specified path is about to be displayed.
	/// Gives the delegate the opportunity to modify the specified cell at
	/// the given row and column location before the browser displays it.
	//var onWillDisplay: RowEventCallback? { get set }
	var onWillDisplay: RowReference? { get set }

	/// Tells that the specified cell was removed from the table
	var onDidEndDisplay: RowReference? { get set }

	/// Message received when a cell at specified path is about to be selected.
	/// If `false` is returned highlight of the cell will be disabled.
	/// If not implemented the default behaviour of the table is to allow highlights of the cell.
	var onShouldHighlight: ((RowProtocol) -> (Bool))? { get set }

	/// Message received when a cell at specified path is about to be selected.
	/// If you return nil cell will be not selected.
	/// If you don't implement this function row is selected normally.
	/// Return the same indexPath of the source or another indexPath to perform a valid selection.
	var onWillSelect: ((RowProtocol) -> (IndexPath?))? { get set }

	/// Message received when a cell at specified path is about to be swiped in order to allow
	/// on or more actions into the context.
	/// You must provide an array of UITableViewRowAction objects representing the actions
	/// for the row. Each action you provide is used to create a button that the user can tap.
	/// By default no swipe actions are returned.
	var onEdit: ((RowProtocol) -> ([UITableViewRowAction]?))? { get set }

	/// Message received when a cell at specified path is about to be removed.
	var onDelete: RowReference? { get set }

	/// Asks the data source whether a given row can be moved to another location in the table view.
	/// If not implemented it return `false` and user is not able to move the row.
	var canMove: ((RowProtocol) -> (Bool))? { get set }

	/// Asks the delegate whether the background of the specified row should be
	/// indented while the table view is in editing mode.
	var shouldIndentOnEditing: ((RowProtocol) -> (Bool))? { get set }

}
