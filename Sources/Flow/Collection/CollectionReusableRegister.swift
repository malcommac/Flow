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

public extension CollectionManager {
	
	/// It keeps the status of the registration of both cell and header/footer reusable identifiers
	public class CollectionReusableRegister {
		
		/// Managed collection
		public private(set) weak var collection: UICollectionView?
		
		/// Registered cell identifiers
		public private(set) var cellIDs: Set<String> = []
		
		/// Registered header identifiers
		public private(set) var headerIDs: Set<String> = []
		
		/// Registered footer identifiers
		public private(set) var footerIDs: Set<String> = []
		
		/// Initialize a new register manager for given collection.
		///
		/// - Parameter collection: collection instance
		internal init(_ collection: UICollectionView) {
			self.collection = collection
		}
		
		/// Register cell defined inside given adapter.
		/// If cell is already registered this operation does nothing.
		///
		/// - Parameter adapter: adapter to register
		@discardableResult
		internal func registerCell(forAdapter adapter: AbstractAdapterProtocol) -> Bool {
			let identifier = adapter.cellReuseIdentifier
			guard !cellIDs.contains(identifier) else {
				return false
			}
			let bundle = Bundle.init(for: adapter.cellClass)
			if let _ = bundle.path(forResource: identifier, ofType: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				collection?.register(nib, forCellWithReuseIdentifier: identifier)
			} else if adapter.registerAsClass {
				collection?.register(adapter.cellClass, forCellWithReuseIdentifier: identifier)
			}
			cellIDs.insert(identifier)
			return true
		}
		
		/// Register header/footer identifier as needed.
		/// If already registered this operation does nothing.
		///
		/// - Parameters:
		///   - headerFooter: header/footer item to register
		///   - type: is it header or footer
		/// - Returns: registered identifier
		@discardableResult
		internal func registerHeaderFooter(_ headerFooter: AbstractCollectionHeaderFooterItem, type: String) -> String {
			let identifier = headerFooter.reuseIdentifier
			if 	(type == UICollectionElementKindSectionHeader && self.headerIDs.contains(identifier)) ||
				(type == UICollectionElementKindSectionFooter && self.footerIDs.contains(identifier)) {
				return identifier
			}
			
			let bundle = Bundle(for: headerFooter.viewClass)
			if let _ = bundle.path(forResource: identifier, ofType: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				collection?.register(nib, forSupplementaryViewOfKind: type, withReuseIdentifier: identifier)
			} else if headerFooter.registerAsClass {
				collection?.register(headerFooter.viewClass, forSupplementaryViewOfKind: type, withReuseIdentifier: identifier)
			}
			return identifier
		}
		
	}

}
