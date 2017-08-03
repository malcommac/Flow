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

open class Section {
	
	/// Specify the model of the header/footer view of a section
	/// If height is not specified the frame's height of passed view is used instead.
	public typealias SectionView = (view: UIView, height: CGFloat?)
	
	/// The rows of this section
	open internal(set) var rows: ObservableArray<RowProtocol> = []
	
	/// Number of rows
	open var countRows: Int {
		return self.rows.count
	}
	
	/// `true` if section does not contains rows
	open var isEmpty: Bool {
		return self.rows.isEmpty
	}
	
	/// Custom header view of the section. It overrides simple header specified as String
	open var headerView: SectionView?
	
	/// Custom footer view of the section. It overrides simple footer specified as String
	open var footerView: SectionView?
	
	/// Simple header as String
	open var headerTitle: String?
	
	/// Simple footer as String
	open var footerTitle: String?
	
	/// Abbreviated title of the section in right table index. `nil` to ignore it.
	open var indexTitle: String?

	/// Initialize a new section of the table without sectiont's footer or header
	/// (You can add it later by using relative properties)
	///
	/// - Parameter rows: rows to allocate in this section
	public init(rows: [RowProtocol]? = nil) {
		if let rows = rows {
			self.rows.append(contentsOf: rows)
		}
	}
	
	/// Initialize a new section with a list of rows and optionally a standard header
	/// and/or footer string.
	///
	/// - Parameters:
	///   - rows: rows to allocate in this section
	///   - header: header title string
	///   - footer: footer title string
	public convenience init(rows: [RowProtocol]? = nil, header: String?, footer: String?) {
		self.init(rows: rows)
		self.headerTitle = header
		self.footerTitle = footer
	}
	
	/// Initialize a new section with a list of rows and optionally an header/footer as a custom
	/// UIView subclass.
	///
	/// - Parameters:
	///   - rows: rows to allocate in this section
	///   - header: header view
	///   - footer: footer view
	public convenience init(rows: [RowProtocol]? = nil, header: SectionView, footer: SectionView) {
		self.init(rows: rows)
		self.headerView = header
		self.footerView = footer
	}
	
	/// Remove all rows from the section
	open func clearAll() {
		self.rows.removeAll()
	}
	
	/// Add a new row into the section optionally specifying the index
	///
	/// - Parameters:
	///   - row: row to add
	///   - index: destination index, if `nil` or not specified the row is append at the end
	open func add(_ row: RowProtocol, at index: Int? = nil) {
		if let index = index {
			self.rows.insert(row, at: index)
		} else {
			self.rows.append(row)
		}
	}
	
	/// Add an array of rows into the section optionally specifying index of the first item to add
	///
	/// - Parameters:
	///   - rows: rows to append
	///   - index: destination index, `nil` to append at the end
	open func add(_ rows: [RowProtocol], at index: Int? = nil) {
		if let index = index {
			self.rows.insert(contentsOf: rows, at: index)
		} else {
			self.rows.append(contentsOf: rows)
		}
	}
	
	/// Replace a row at specified row
	///
	/// - Parameters:
	///   - index: index of row to replace
	///   - row: new row
	open func replace(rowAt index: Int, with row: RowProtocol) {
		guard index < self.rows.count else { return }
		self.rows[index] = row
	}
	
	/// Remove a row at specified index
	///
	/// - Parameter index: index
	open func remove(rowAt index: Int) {
		self.rows.remove(at: index)
	}

}
