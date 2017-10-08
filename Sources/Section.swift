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

/// Type of section
///
/// - header: section is an header
/// - footer: section is a footer
public enum SectionType {
	case header
	case footer
}

/// Section represent a single Table's section. It contains rows, may have an header or a footer.
open class Section: Equatable, Hashable {
	
	/// The rows of this section
	open internal(set) var rows: ObservableArray<RowProtocol> = []
	
	/// Reference to parent manager
	internal weak var manager: TableManager? = nil
	
	/// Identifier string for this ection
	open var identifier: String? = nil
	
	/// Index of the section in parent manager (if any).
	/// Return `nil` if not found.
	public var index: Int? {
		get { return self.manager?.sections.index(of: self) }
	}
	
	/// Number of rows
	open var countRows: Int {
		return self.rows.count
	}
	
	/// `true` if section does not contains rows
	open var isEmpty: Bool {
		return self.rows.isEmpty
	}
	
	/// Custom header view of the section.
	/// It overrides simple header specified as String
	open var headerView: SectionProtocol?
	
	/// Custom footer view of the section.
	/// It overrides simple footer specified as String
	open var footerView: SectionProtocol?
	
	/// Simple header as String
	open var headerTitle: String?
	
	/// Simple footer as String
	open var footerTitle: String?
	
	/// Abbreviated title of the section in right table index. `nil` to ignore it.
	open var indexTitle: String?

	/// Initialize a new section of the table without sectiont's footer or header
	/// (You can add it later by using relative properties)	///
	/// - Parameters:
	///   - id: optional identifier of the section
	///   - rows: rows to allocate in this section
	public init(id: String? = nil, rows: [RowProtocol]? = nil) {
		self.identifier = id
		if let rows = rows {
			self.rows.append(contentsOf: rows)
		}
	}
	
	/// Initialize a new section with a single passed row
	///
	/// - Parameters:
	///   - id: optional identifier of the section
	///   - row: row to add
	public init(id: String? = nil, row: RowProtocol) {
		self.identifier = id
		self.rows = [row]
	}

	/// Initialize a new section with a list of rows and optionally a standard header
	/// and/or footer string.
	///
	/// - Parameters:
	///   - id: optional identifier of the section
	///   - rows: rows to allocate in this section
	///   - header: header title string
	///   - footer: footer title string
	public convenience init(id: String? = nil, _ rows: [RowProtocol]? = nil, header: String? = nil, footer: String? = nil) {
		self.init(id: id, rows: rows)
		self.headerTitle = header
		self.footerTitle = footer
	}
	
	/// Initialize a new section with a list of rows and optionally an header/footer as a custom
	/// UIView subclass.
	///
	/// - Parameters:
	///   - id: optional identifier of the section
	///   - rows: rows to allocate in this section
	///   - header: header view
	///   - footer: footer view
	public convenience init(id: String? = nil, _ rows: [RowProtocol]? = nil, headerView: SectionProtocol? = nil, footerView: SectionProtocol? = nil) {
		self.init(id: id, rows: rows)
		self.headerView = headerView
		self.footerView = footerView
	}
	
	/// Reload this section
	///
	/// - Parameter anim: animation to use; if nil `automatic` will be used
	public func reload(_ anim: UITableViewRowAnimation? = nil) {
		guard let index = self.index else { return }
		self.manager?.tableView?.reloadSections(IndexSet(integer: index), with: (anim ?? .automatic))
	}
	
	/// Reload rows at specified indexes.
	///
	/// - Parameters:
	///   - indexes: indexes of rows to reload
	///   - animation: animation to use, `automatic` is used when `nil` is passed.
	open func reload(rowsAtIndexes indexes: [IndexPath], animation: UITableViewRowAnimation? = nil) {
		self.manager?.tableView?.reloadRows(at: indexes, with: animation ?? .automatic)
	}

	
	/// Reload row with given identifier.
	///
	/// - Parameters:
	///   - id: identifier of the row
	///   - animation: animation to use, `automatic` is used when `nil` is passed.
	open func reload(rowWithID id: String, animation: UITableViewRowAnimation? = nil) {
		guard let rowIdx = self.rows.index(where: { $0.identifier == id }) else { return }
		let indexPath = IndexPath(row: rowIdx, section: self.index!)
		self.manager?.tableView?.reloadRows(at: [indexPath], with: animation ?? .automatic)
	}
	
	/// Reload rows with given IDs
	///
	/// - Parameters:
	///   - ids: ids to search
	///   - animation: animation to use, `automatic` is used when `nil` is passed.
	open func reload(rowsWithIDs ids: [String], animation: UITableViewRowAnimation? = nil) {
		let sectionIdx = self.index!
		var indexes: [IndexPath] = []
		self.rows.enumerated().forEach { rowIdx,item in
			if let id = item.identifier, ids.contains(id) {
				indexes.append(IndexPath(row: rowIdx, section: sectionIdx))
			}
		}
		guard indexes.count > 0 else { return }
		self.manager?.tableView?.reloadRows(at: indexes, with: animation ?? .automatic)
	}
	
	
	/// Get rows with given identifiers
	///
	/// - Parameter ids: identifiers to search
	/// - Returns: instances of `RowProtocol`
	open func rows(withIDs ids: [String]) -> [RowProtocol] {
		return self.rows.filter({
			guard let id = $0.identifier, ids.contains(id) else { return false }
			return true
		})
	}
	
	/// Get the first row with given identifier
	///
	/// - Parameter id: identifier to search
	/// - Returns: found instance, `nil` if nothing were found
	open func row(withID id: String) -> RowProtocol? {
		return self.rows.find(predicate: { $0.identifier == id })
	}
	
	/// Remove all rows from the section
	open func clearAll() {
		self.manager?.keepRemovedRows(Array(self.rows))
		self.rows.removeAll()
	}
	
	/// Return the standard title (string) for header/footer of the section
	///
	/// - Parameter type: type of data
	/// - Returns: string, `nil` if not set
	internal func sectionTitle(forType type: SectionType) -> String? {
		return (type == .header ? self.headerTitle : self.footerTitle)
	}
	
	/// Return the custom view which represent the section header/footer requested
	///
	/// - Parameter type: type of view
	/// - Returns: instance, `nil` if not set
	internal func view(forType type: SectionType) -> SectionProtocol? {
		return (type == .header ? self.headerView : self.footerView)
	}
	
	/// Add a new row into the section optionally specifying the index
	///
	/// - Parameters:
	///   - row: row to add
	///   - index: destination index, if `nil` or not specified the row is append at the end
	@discardableResult
	open func add(_ row: RowProtocol, at index: Int? = nil) -> RowProtocol {
		if let index = index {
			self.rows.insert(row, at: index)
		} else {
			self.rows.append(row)
		}
		return row
	}
	
	/// Add an array of rows into the section optionally specifying index of the first item to add
	///
	/// - Parameters:
	///   - rows: rows to append
	///   - index: destination index, `nil` to append at the end
	@discardableResult
	open func add(_ rows: [RowProtocol], at index: Int? = nil) -> [RowProtocol] {
		if let index = index {
			self.rows.insert(contentsOf: rows, at: index)
		} else {
			self.rows.append(contentsOf: rows)
		}
		return rows
	}
	
	/// Replace a row at specified row
	///
	/// - Parameters:
	///   - index: index of row to replace
	///   - row: new row
	@discardableResult
	open func replace(rowAt index: Int, with row: RowProtocol) -> RowProtocol {
		guard index < self.rows.count else { return row }
		self.manager?.keepRemovedRows([self.rows[index]])
		self.rows[index] = row
		return row
	}
	
	/// Remove a row at specified index
	///
	/// - Parameter index: index
	@discardableResult
	open func remove(rowAt index: Int) -> RowProtocol {
		let removed = self.rows.remove(at: index)
		self.manager?.keepRemovedRows([removed])
		return removed
	}
	
	/// Equatable protocol
	///
	/// - Parameters:
	///   - lhs: left operand
	///   - rhs: right operand
	/// - Returns: `true` if both sections are equals, `false` otherwise
	public static func ==(lhs: Section, rhs: Section) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	/// Unique identifier for section
	private var UUID: NSUUID = NSUUID()
	
	/// Hash value
	public var hashValue: Int {
		return UUID.uuidString.hashValue
	}
}
