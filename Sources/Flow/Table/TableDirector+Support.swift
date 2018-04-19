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

// TableDirector Events

internal protocol TableDirectorEventable {
	var name: TableDirectorEventKey { get }
}

internal enum TableDirectorEventKey: String {
	case sectionForSectionIndex
}

public extension TableDirector {
	
	/// Available events for TableDirector.
	///
	/// - sectionForSectionIndex->: Asks to return the index of the section having the given title and section title index (`tableView(_:sectionForSectionIndexTitle:at:)`). Section titles are obtained from `indexTitle` of each `TableSection`.
	public enum Event: TableDirectorEventable {
		case sectionForSectionIndex(_: (_ title: String, _ index: Int) -> (Int))
	
		var name: TableDirectorEventKey {
			switch self {
			case .sectionForSectionIndex:	return .sectionForSectionIndex
			}
		}
	}
	
}

/// Animations used with reload
public struct TableReloadAnimations {
	
	public var rowDeletionAnimation: UITableViewRowAnimation 		= .automatic
	public var rowInsertionAnimation: UITableViewRowAnimation 		= .automatic
	public var rowReloadAnimation: UITableViewRowAnimation 			= .automatic
	
	public var sectionDeletionAnimation: UITableViewRowAnimation 	= .automatic
	public var sectionInsertionAnimation: UITableViewRowAnimation 	= .automatic
	public var sectionReloadAnimation: UITableViewRowAnimation 		= .automatic

	public init() { }
	
	public static func `default`() -> TableReloadAnimations {
		return TableReloadAnimations()
	}
}

// Protocols

public protocol AbstractTableHeaderFooterItem : AbstractCollectionReusableView { }

extension UITableViewCell: CellProtocol { }

public protocol TableAdapterProtocol : AbstractAdapterProtocol, Equatable { }

internal protocol TableAdaterProtocolFunctions {
	
	@discardableResult
	func dispatch(_ event: TableAdapterEventsKey, context: InternalContext) -> Any?
	
	// Dequeue (UITableViewDatasource)
	func _instanceCell(in table: UITableView, at indexPath: IndexPath?) -> UITableViewCell
}
