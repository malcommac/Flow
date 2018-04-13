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

public class CollectionSectionView<T: HeaderFooterProtocol>: AbstractCollectionHeaderFooterItem, CustomStringConvertible {
	
	/// Context of the event sent to section's view.
	public struct Context<T> {
		
		/// Parent collection
		public private(set) weak var collection: UICollectionView?
		
		/// Instance of the view dequeued for this section.
		public private(set) var view: T?
		
		/// Index of the section.
		public private(set) var section: Int
		
		/// Parent collection's size.
		public var collectionSize: CGSize? {
			return self.collection?.bounds.size
		}
		
		/// Initialize a new context (private).
		public init(view: T?, at section: Int, of collection: UICollectionView) {
			self.collection = collection
			self.view = view
			self.section = section
		}
	}
	
	//MARK: PROPERTIES
	
	/// Event called when the view is dequeued and ready to be configured.
	public var onConfigure : ((Context<T>) -> (Void))? = nil
	
	/// Return the size of the view.
	public var onGetReferenceSize: ((Context<T>) -> (CGSize))? = nil
	
	/// Event called when view is displayed.
	public var onDidDisplay: ((Context<T>) -> (Void))? = nil
	
	/// Event called when view is removed from the collection.
	public var onEndDisplay: ((Context<T>) -> (Void))? = nil
	
	public var viewClass: AnyClass { return T.self }
	
	public var reuseIdentifier: String { return T.reuseIdentifier }
	
	public var registerAsClass: Bool { return T.registerAsClass }
	
	public var description: String {
		return "CollectionSectionView<\(String(describing: type(of: T.self)))>"
	}
	
	//MARK: INIT
	
	/// Initialize a new section view.
	///
	/// - Parameter configuration: configuration callback
	public init(_ configuration: ((CollectionSectionView) -> (Void))) {
		configuration(self)
	}
	
	//MARK: INTERNAL METHODS
	
	public func _configure(view: UICollectionReusableView, section: Int, collection: UICollectionView) {
		guard let event = onConfigure else { return }
		let context = Context<T>(view: view as? T, at: section, of: collection)
		event(context)
	}
	
	public func _referenceSize(section: Int, collection: UICollectionView) -> CGSize {
		guard let event = self.onGetReferenceSize else {
			fatalError("referenceSize is not implement for \(self)")
		}
		let context = Context<T>(view: nil, at: section, of: collection)
		return event(context)
	}
	
	public func _didDisplay(view: UICollectionReusableView, section: Int, collection: UICollectionView) {
		guard let event = onDidDisplay else { return }
		let context = Context<T>(view: view as? T, at: section, of: collection)
		event(context)
	}
	
	public func _didEndDisplay(view: UICollectionReusableView, section: Int, collection: UICollectionView) {
		guard let event = onEndDisplay, let v = view as? T else { return }
		let context = Context<T>(view: v, at: section, of: collection)
		event(context)
	}
	
}
