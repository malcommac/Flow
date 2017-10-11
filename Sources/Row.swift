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

open class Row<Cell: DeclarativeCell>: RowProtocol where Cell: UITableViewCell {
	
	public typealias TableRowConfigurator = ((_ maker: Row) -> (Void))
	
	/// Item represented by the cell
	open let model: Cell.T
	
	/// Optional identifier of the row
	public var identifier: String? = nil

	/// Hash value
	public var hashValue: Int {
		return ObjectIdentifier(self).hashValue
	}
	
	/// Reuse identifier of the cell
	public var reuseIdentifier: String {
		return Cell.reuseIdentifier
	}
	
	/// When associated cell instance is dequeued this contains
	/// the indexPath of the cell itself.
	/// You should not modify it.
	public var _indexPath: IndexPath?
	public var indexPath: IndexPath? {
		get { return self._indexPath }
	}

	/// Internal reference (weak) to cell instance.
	/// You should not reference to it (we cannot assign private var in
	/// protocols yet); use `cell` property instead, it will return
	/// the instance of the cell used to represent the row itself.
	public weak var _instance: UITableViewCell?

	/// Weak reference to cell instances
	public var cell: Cell? {
		get { return _instance as? Cell }
	}
	
	/// Estimated height of the cell. Used when autosizing is enabled
	public var evaluateEstimatedHeight: (() -> (CGFloat?))? = nil

	/// Fixed height for cell
	public var evaluateRowHeight: (() -> (CGFloat?))? = nil
	
	/// Private
	public var _estimatedHeight: CGFloat? {
		return Cell.estimatedHeight
	}
	
    /// You can use this value if your row has a fixed height.
    /// By setting a non `nil` value your both `evaluateEstimatedHeight` and
    /// `evaluateRowHeight` will be ignored.
    public var rowHeight: CGFloat? = nil
    
    /// You can use this value to disable or enable highlight of the cell.
    /// If non `nil` value is set `onShouldHighlight` will be not called.
    public var shouldHighlight: Bool? = nil
    
	/// Fixed height of the cell
	/// If you have not provided a valid height at instance level for given `Row` this is the
	/// last chance to return a valid value. This method is called statically and you can implement
	/// it if your cell does need to change the height but has a fixed height value (or automatic one).
	public var _defaultHeight: CGFloat? {
		return Cell.defaultHeight
	}
	
	/// Static level highlight of the cell.
	/// This method is called statically and you can implement it in your cell.
	public var _shouldHighlight: Bool? {
		return Cell.shouldHightlight
	}
	
	/// Class which represent the cell
	public var cellType: AnyClass {
		return Cell.self
	}
	
	/// Configure cell
	///
	/// - Parameter cell: cell instance
	open func configure(_ instance: UITableViewCell, path: IndexPath) {
		self._instance = instance // set instance of the cell
		self._indexPath = path // set the indexPath of the cell
		self.cell?.configure(self.model, path: path)
	}
	
	/// Message received when a cell instance has been dequeued from table
	public var onDequeue: RowProtocol.RowReference? = nil

	/// Message received when user tap on a cell at specified path. You must provide a default behaviour
	/// by returning one of the `RowTapBehaviour` options. If `nil` is provided the default
	/// behaviour is `deselect` with animation.
	public var onTap: ((RowProtocol) -> (RowTapBehaviour?))? = nil

	/// Message received when a cell at specified path is about to be removed.
	public var onDelete: RowReference? = nil

	/// Message received when a selection has been made. Selection still active only if
	/// `onTap` returned `.keepSelection` option.
	public var onSelect: RowReference? = nil

	/// Message received when a cell at specified path is about to be swiped in order to allow
	/// on or more actions into the context.
	/// You must provide an array of UITableViewRowAction objects representing the actions
	/// for the row. Each action you provide is used to create a button that the user can tap.
	/// By default no swipe actions are returned.
	public var onEdit: ((RowProtocol) -> ([UITableViewRowAction]?))? = nil

	/// Message received when cell at specified path did deselected
	public var onDeselect: RowReference? = nil

	/// Message received when a cell at specified path is about to be displayed.
	/// Gives the delegate the opportunity to modify the specified cell at
	/// the given row and column location before the browser displays it.
	public var onWillDisplay: RowReference? = nil

	/// The cell was removed from the table
	public var onDidEndDisplay: RowReference? = nil

	/// Message received when a cell at specified path is about to be selected.
	public var onWillSelect: ((RowProtocol) -> (IndexPath?))? = nil

	/// Message received when a cell at specified path is about to be selected.
	/// If `false` is returned highlight of the cell will be disabled.
	/// If not implemented the default behaviour of the table is to allow highlights of the cell.
	public var onShouldHighlight: ((RowProtocol) -> (Bool))? = nil

	/// Asks the data source whether a given row can be moved to another location in the table view.
	/// If not implemented `false` is assumed instead.
	public var canMove: ((RowProtocol) -> (Bool))? = nil

	/// Asks the delegate whether the background of the specified row should be
	/// indented while the table view is in editing mode.
	/// If not implemented `true` is returned.
	public var shouldIndentOnEditing: ((RowProtocol) -> (Bool))? = nil

	/// Initialize a new row
	///
	/// - Parameters:
	///   - item: item represented by the row
	///   - maker: maker block to configure the object
	public init(id identifier: String? = nil, model: Cell.T, _ configurator: TableRowConfigurator? = nil) {
		self.identifier = identifier
		self.model = model
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
		return items.map { Row(model: $0, configurator) }
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
	
	/// If you want to disable highlight of the row without doing any conditions check you
	/// can set this value directly as cell property.
	/// It will override any `onShouldHighlight` event of the `RowProtocol`.
	static var shouldHightlight: Bool? { get }
	
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
	
	/// Default height of the cell, if applicable
	static var shouldHightlight: Bool? {
		return nil
	}
	
	static public func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
