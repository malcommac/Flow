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

/// Represent a single section of the collection.
public class CollectionSection: Equatable, Hashable {
	
	/// Identifier of the section
	internal var UUID: String = NSUUID().uuidString
	
	/// Items inside the collection
	public private(set) var items: [ModelProtocol]
	
	/// Implement this method when you want to provide margins for sections in the flow layout.
	/// If you do not implement this method, the margins are obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var sectionInsets: UIEdgeInsets? = nil
	
	/// The minimum spacing (in points) to use between items in the same row or column.
	/// If you do not implement this method, value is obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var minimumInterItemSpacing: CGFloat? = nil
	
	/// The minimum spacing (in points) to use between rows or columns.
	/// If you do not implement this method, value is obtained from the properties of the flow layout object.
	/// NOTE: It's valid only for flow layout.
	open var minimumLineSpacing: CGFloat? = nil
	
	/// Header of the sections; instantiate a new object of `CollectionSectionView<UIReusableView>`.
	/// NOTE: It's valid only for flow layout.
	open var header: AbstractCollectionHeaderFooterItem? = nil
	
	/// Footer of the sections; instantiate a new object of `CollectionSectionView<UIReusableView>`.
	/// NOTE: It's valid only for flow layout.
	open var footer: AbstractCollectionHeaderFooterItem? = nil
	
	/// Temporary removed models, it's used to pass the correct model
	/// to didEndDisplay event; after sent it will be removed automatically.
	private var temporaryRemovedModels: [IndexPath : ModelProtocol] = [:]
	
	/// Managed manager
	private weak var manager: CollectionDirector?
	
	/// Index of the section in manager.
	/// If section is not part of a manager it returns `nil`.
	private var index: Int? {
		guard let m = manager, let idx = m.sections.index(of: self) else { return nil }
		return idx
	}
	
	/// Initialize a new section with given objects as items.
	///
	/// - Parameter items: items, `nil` create an empty set.
	public init(_ items: [ModelProtocol]?) {
		self.items = (items ?? [])
	}
	
	/// Add items into the section at given index.
	///
	/// - Parameters:
	///   - items: items to add.
	///   - index: starting index, if `nil` items are added at the bottom of the list.
	public func add(_ items: [ModelProtocol], at index: Int? = nil) {
		guard let i = index else {
			self.items.append(contentsOf: items)
			return
		}
		self.items.insert(contentsOf: items, at: i)
	}
	
	/// Add item into the section at given index.
	///
	/// - Parameters:
	///   - item: item to add.
	///   - index: destination index; if `nil` item is added at the bottom of the list.
	public func add(_ item: ModelProtocol, at index: Int? = nil) {
		guard let i = index else {
			self.items.append(item)
			return
		}
		self.items.insert(item, at: i)
	}
	
	/// Remove item at given index.
	///
	/// - Parameter index: index of the item to remove; if invalid it silently fail.
	/// - Returns: removed item or `nil`.
	@discardableResult
	public func remove(at index: Int) -> ModelProtocol? {
		guard index < self.items.count else { return nil }
		let removed = self.items.remove(at: index)
		return removed
	}
	
	/// Remove items at indexes.
	///
	/// - Parameter indexes: index of the items to remove.
	/// - Returns: removed items
	@discardableResult
	public func remove(indexes: IndexSet) -> [ModelProtocol]? {
		var removed: [ModelProtocol] = []
		indexes.reversed().forEach { removed.append(self.items.remove(at: $0)) }
		return removed.reversed()
	}
	
	public static func == (lhs: CollectionSection, rhs: CollectionSection) -> Bool {
		return (lhs.UUID == rhs.UUID)
	}
	
	public var hashValue: Int {
		return self.UUID.hashValue
	}

}
