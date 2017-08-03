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

open class Row<Cell: DeclarativeCell>: RowProtocol where Cell: UITableViewCell {
	
	public typealias TableRowConfigurator = ((_ maker: Row) -> (Void))

	/// Item represented by the cell
	open let item: Cell.T
	
	/// Hash value
	public var hashValue: Int {
		return ObjectIdentifier(self).hashValue
	}
	
	/// Reuse identifier of the cell
	public var reuseIdentifier: String {
		return Cell.reuseIdentifier
	}
	
	/// Estimated height of the cell. Used when autosizing is enabled
	public var evaluateEstimatedHeight: ((Void) -> (CGFloat?))? = nil

	/// Fixed height for cell
	public var evaluateRowHeight: ((Void) -> (CGFloat?))? = nil
	
	
	/// Private
	public var estimatedHeight: CGFloat? {
		return Cell.estimatedHeight
	}
	
	/// Fixed height of the cell
	/// If you have not provided a valid height at instance level for given `Row` this is the
	/// last chance to return a valid value. This method is called statically and you can implement
	/// it if your cell does need to change the height but has a fixed height value (or automatic one).
	public var defaultHeight: CGFloat? {
		return Cell.defaultHeight
	}
	
	/// Class which represent the cell
	public var cellType: AnyClass {
		return Cell.self
	}
	
	/// Configure cell
	///
	/// - Parameter cell: cell instance
	open func configure(_ cell: UITableViewCell, path: IndexPath) {
		(cell as? Cell)?.configure(self.item, path: path)
	}
	
	/// Message received when a cell instance has been dequeued from table
	public var onDequeue: RowProtocol.RowEventCallback? = nil
	
	/// Message received when user tap on a cell at specified path. You must provide a default behaviour
	/// by returning one of the `RowTapBehaviour` options. If `nil` is provided the default
	/// behaviour is `deselect` with animation.
	public var onTap: ((RowProtocol.RowInfo) -> (RowTapBehaviour))? = nil
	
	/// Message received when a selection has been made. Selection still active only if
	/// `onTap` returned `.keepSelection` option.
	public var onDelete: RowProtocol.RowEventCallback? = nil
	
	/// Message received when a selection has been made. Selection still active only if
	/// `onTap` returned `.keepSelection` option.
	public var onSelect: RowProtocol.RowEventCallback? = nil
	
	/// Message received when a cell at specified path is about to be swiped in order to allow
	/// on or more actions into the context.
	/// You must provide an array of UITableViewRowAction objects representing the actions
	/// for the row. Each action you provide is used to create a button that the user can tap.
	/// By default no swipe actions are returned.
	public var onEdit: ((RowProtocol.RowInfo) -> ([UITableViewRowAction]?))? = nil
	
	/// Message received when cell at specified path did deselected
	public var onDeselect: RowProtocol.RowEventCallback? = nil
	
	/// Message received when a cell at specified path is about to be displayed.
	/// Gives the delegate the opportunity to modify the specified cell at
	/// the given row and column location before the browser displays it.
	public var onWillDisplay: RowProtocol.RowEventCallback? = nil
	
	/// Message received when a cell at specified path is about to be selected.
	public var onWillSelect: ((RowProtocol.RowInfo) -> (IndexPath?))? = nil
	
	/// Message received when a cell at specified path is about to be selected.
	/// If `false` is returned highlight of the cell will be disabled.
	/// If not implemented the default behaviour of the table is to allow highlights of the cell.
	public var onShouldHighlight: ((RowProtocol.RowInfo) -> (Bool))? = nil
	
	/// Initialize a new row
	///
	/// - Parameters:
	///   - item: item represented by the row
	///   - maker: maker block to configure the object
	public init(_ item: Cell.T, _ configurator: TableRowConfigurator? = nil) {
		self.item = item
		configurator?(self)
	}
	
	/// Create a new set of rows of the same type with the same maker
	///
	/// - Parameters:
	///   - count: number of cells
	///   - item: item represented by the row
	///   - maker: maker block to configure the object
	/// - Returns: a list of the row
	public static func create(_ items: [Cell.T], _ configurator: TableRowConfigurator? = nil) -> [Row] {
		guard items.count > 0 else { return [] }
		return items.map { Row($0, configurator) }
	}
}

public protocol DeclarativeCell: class {
	
	associatedtype T
	
	/// Identifier of the cell. Default implementation has the same name of the class itself.
	static var reuseIdentifier: String { get }
	
	/// Estimated height of the cell at static level.
	/// You want to provide a value for this variable only if your cell doesn't have height based
	/// upon the content.
	static var estimatedHeight: CGFloat? { get }
	
	/// Estimated height of the cell at static level.
	/// You want to provide a value for this variable only if your cell doesn't have height based
	/// upon the content (you may, however, return `UITableViewAutomaticDimension` if needed)
	static var defaultHeight: CGFloat? { get }
	
	/// Configure a cell instance just after the dequeue from table instance
	///
	/// - Parameters:
	///   - _: item to render
	///   - path: index path
	func configure(_: T, path: IndexPath)
	
}

public extension DeclarativeCell where Self: UITableViewCell {
	
	/// By default reuseIdentifier uses the name of the class you have used
	/// to declare this cell. This simple rule avoid confusion with naming and produce
	/// consistent results across your code.
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	/// Estimated height of the cell, if applicable
	static var estimatedHeight: CGFloat? {
		return nil
	}
	
	/// Default height of the cell, if applicable
	static var defaultHeight: CGFloat? {
		return nil
	}
	
	static public func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
