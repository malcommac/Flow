//
//	Flow: Manage Tables Easily
//	--------------------------------------
//	Created by:	Daniele Margutti
//	Email:		hello@danielemargutti.com
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
	
	typealias RowInfo = (_: UITableViewCell?, _: IndexPath)
	typealias RowEventCallback = ((RowInfo) -> (Void))
	
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
	var evaluateEstimatedHeight: ((Void) -> (CGFloat?))? { get set }

	/// Allows the user to return the height of the cell.
	/// This is done at runtime level when a single instance of the Row is about to be displayed.
	/// You can return a fixed height or `UITableViewAutomaticDimension`.
	/// If you return `nil` the result of the method is ignored and the request is made statically
	/// to the `defaultHeight` of the provided cell class.
	/// If, even this method, return `nil` `TableManager` attempt to evaluate the height of the cell
	/// by creating it and getting the size of the `contentView`.
	var evaluateRowHeight: ((Void) -> (CGFloat?))? { get set }
	
	/// This is for internal purpose only.
	var estimatedHeight: CGFloat? { get }
	
	/// This is for internal purpose only.
	var defaultHeight: CGFloat? { get }
		
	/// Allows the user to configure the cell instance
	///
	/// - Parameters:
	///   - cell: cell instance to configure
	///   - path: destination indexPath of the cell
	func configure(_ cell: UITableViewCell, path: IndexPath)

	/// hash value of the row
	var hashValue: Int { get }

	/// Message received when a cell instance has been made
	var onDequeue: RowEventCallback? { get set }
	
	/// Message received when user tap on a cell at specified path. You must provide a default behaviour
	/// by returning one of the `RowTapBehaviour` options. If `nil` is provided the default
	/// behaviour is `deselect` with animation.
	var onTap: ((RowInfo) -> (RowTapBehaviour?))? { get set }
	
	/// Message received when a selection has been made. Selection still active only if
	/// `onTap` returned `.keepSelection` option.
	var onSelect: RowEventCallback? { get set }
	
	/// Message received when cell at specified path did deselected
	var onDeselect: RowEventCallback? { get set }
	
	/// Message received when a cell at specified path is about to be displayed.
	/// Gives the delegate the opportunity to modify the specified cell at
	/// the given row and column location before the browser displays it.
	var onWillDisplay: RowEventCallback? { get set }
	
	/// Message received when a cell at specified path is about to be selected.
	/// If `false` is returned highlight of the cell will be disabled.
	/// If not implemented the default behaviour of the table is to allow highlights of the cell.
	var onShouldHighlight: ((RowInfo) -> (Bool))? { get set }
	
	/// Message received when a cell at specified path is about to be selected.
	/// If you return nil cell will be not selected.
	/// If you don't implement this function row is selected normally.
	/// Return the same indexPath of the source or another indexPath to perform a valid selection.
	var onWillSelect: ((RowInfo) -> (IndexPath?))? { get set }
	
	/// Message received when a cell at specified path is about to be swiped in order to allow
	/// on or more actions into the context.
	/// You must provide an array of UITableViewRowAction objects representing the actions
	/// for the row. Each action you provide is used to create a button that the user can tap.
	/// By default no swipe actions are returned.
	var onEdit: ((RowInfo) -> ([UITableViewRowAction]?))? { get set }
	
	/// Message received when a cell at specified path is about to be removed.
	var onDelete: RowEventCallback? { get set }

}
