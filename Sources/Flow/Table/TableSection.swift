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

/// Represent a single section of the table
public class TableSection: Hashable {
	
	/// Registered events for this section.
	//internal var events: [TableSectionEventKey : TableSectionEvents] = [:]
	public var on = TableSection.Events()
	
	/// Items inside the section.
	public private(set) var items: [ModelProtocol] = []
	
	/// Title of the header; if `headerView` is set this value is ignored.
	public var headerTitle: String?
	
	/// Title of the footer; if `footerView` is set this value is ignored.
	public var footerTitle: String?
	
	/// View of the header
	public var headerView: AbstractTableHeaderFooterItem?
	
	/// View of the footer
	public var footerView: AbstractTableHeaderFooterItem?
	
	/// Optional index title for this section (used for `sectionIndexTitles(for: UITableView)`)
	public var indexTitle: String?
	
	/// Unique identifier of the section
	public let UUID: String = NSUUID().uuidString
	
	/// Initialize a new section with given initial items.
	///
	/// - Parameter items: items to add (`nil` means empty array)
	public init(_ items: [ModelProtocol]?) {
		self.items = (items ?? [])
	}
	
	/// Initialize a new section with given header/footer's titles and initial items.
	///
	/// - Parameters:
	///   - headerTitle: header title as string
	///   - footerTitle: footer title as string
	///   - items: items to add (`nil` means empty array)
	public convenience init(headerTitle: String?, footerTitle: String?,
							items: [ModelProtocol]? = nil) {
		self.init(items)
		self.headerTitle = headerTitle
		self.footerTitle = footerTitle
	}
	
	/// Initialize a new section with given view for header/footer and initial items.
	///
	/// - Parameters:
	///   - headerView: header view
	///   - footerView: footer view
	///   - items: items to add (`nil` means empty array)
	public convenience init(headerView: AbstractTableHeaderFooterItem?, footerView: AbstractTableHeaderFooterItem?,
							items: [ModelProtocol]? = nil) {
		self.init(items)
		self.headerView = headerView
		self.footerView = footerView
	}
	
	public var hashValue: Int {
		return self.UUID.hashValue
	}
	
	public static func == (lhs: TableSection, rhs: TableSection) -> Bool {
		return (lhs.UUID == rhs.UUID)
	}
	
}
