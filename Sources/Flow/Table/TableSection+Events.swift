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

/// Events you can register for a `TableSection`.
///
/// - headerHeight->CGFloat: Asks for the height to use for the header of a particular section (`tableView(_:heightForHeaderInSection:)`)
/// - footerHeight->CGFloat: Asks for the height to use for the footer of a particular section (`tableView(_:heightForFooterInSection:)`)
/// - estimatedHeaderHeight->CGFloat: Ask for the estimated height of the header of a particular section (`tableView(_:estimatedHeightForHeaderInSection:)`)
/// - estimatedFooterHeight->CGFloat: Asks for the estimated height of the footer of a particular section (`tableView(_:estimatedHeightForFooterInSection:)`)
/// - willDisplayHeader->Void: Tells that a header view is about to be displayed for the specified section (`tableView(_:willDisplayHeaderView:forSection:)`)
/// - willDisplayFooter->Void: Tells that a footer view is about to be displayed for the specified section (`tableView(_:willDisplayFooterView:forSection:)`)
/// - didEndDisplayHeader->Void: Tells that the specified header view was removed from the table (`tableView(_:didEndDisplayingHeaderView:forSection:)`)
/// - didEndDisplayFooter->Void: Tells that the specified footer view was removed from the table (`tableView(_:didEndDisplayingFooterView:forSection:)tableView(_:didEndDisplayingFooterView:forSection:`)
/*public enum TableSectionEvents: TableSectionEventable {
	case headerHeight(_: (() -> CGFloat))
	case footerHeight(_: (() -> CGFloat))
	case estimatedHeaderHeight(_: (() -> CGFloat))
	case estimatedFooterHeight(_: (() -> CGFloat))
	case willDisplayHeader(_: ((UIView) -> Void))
	case willDisplayFooter(_: ((UIView) -> Void))
	case didEndDisplayHeader(_: ((UIView) -> Void))
	case didEndDisplayFooter(_: ((UIView) -> Void))
	
	var name: TableSectionEventKey {
		switch self {
		case .headerHeight:				return .headerHeight
		case .footerHeight:				return .footerHeight
		case .estimatedHeaderHeight:	return .estimatedHeaderHeight
		case .estimatedFooterHeight:	return .estimatedFooterHeight
		case .willDisplayHeader:		return .willDisplayHeader
		case .willDisplayFooter:		return .willDisplayFooter
		case .didEndDisplayHeader:		return .didEndDisplayHeader
		case .didEndDisplayFooter:		return .didEndDisplayFooter
		}
	}
	
}

/// Internal Event Register Hooks

internal protocol TableSectionEventable {
	var name: TableSectionEventKey { get }
}

internal enum TableSectionEventKey: String {
	case headerHeight
	case footerHeight
	case estimatedHeaderHeight
	case estimatedFooterHeight
	case willDisplayHeader
	case willDisplayFooter
	case didEndDisplayHeader
	case didEndDisplayFooter
}
*/
