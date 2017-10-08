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


/// This represent a custom view for a section's header or footer
open class SectionView<View: DeclarativeView>: SectionProtocol where View: UITableViewHeaderFooterView {
	
	public typealias SectionViewConfigurator = ((_ maker: SectionView) -> (Void))

	/// Class which represent the item of the section
	open let item: View.T
	
	/// Reuse identifier to cache the section. By default its rely to the
	/// subclass of the `UITableViewHeaderFooterView`.
	public var reuseIdentifier: String {
		return View.reuseIdentifier
	}
	
	/// Hash value
	public var hashValue: Int {
		return ObjectIdentifier(self).hashValue
	}
	
	/// Allows the user to estimate the height of a section (footer or header).
	/// If returned value is `nil` it Flow attempts to use the static `estimatedHeight` property.
	/// If even it returns `nil` the automatic dimension size is returned instead.
	public var evaluateEstimatedHeight: ((SectionType) -> (CGFloat?))? = nil
	
	/// Allows the user to evaluate the height of a section (footer or header).
	/// If returned value is `nil` it Flow attempts to use the static `defaultHeight` property.
	/// If even it returns `nil` the automatic dimension size is returned instead.
	public var evaluateViewHeight: ((SectionType) -> (CGFloat?))? = nil
	
	/// Rely to the `UITableViewHeaderFooterView` specified subclass implementation
	public var estimatedHeight: CGFloat? {
		return View.estimatedHeight
	}
	
	/// Rely to the `UITableViewHeaderFooterView` specified subclass implementation
	public var defaultHeight: CGFloat? {
		return View.defaultHeight
	}
	
	/// Subclass of `UITableViewHeaderFooterView`
	public var viewType: AnyClass {
		return View.self
	}
	
	/// Event called when a section is dequeued
	public var onDequeue: SectionEventCallback? = nil
	
	/// Event called when a section's view will be displayed
	public var onWillDisplay: SectionEventCallback? = nil
	
	/// Event called when a section did removed from the table
	public var didEndDisplaying: SectionEventCallback? = nil
	
	/// Configure the instance of the view in a given section
	///
	/// - Parameters:
	///   - view: instance to configure (your subclass of `UITableViewHeaderFooterView`)
	///   - type: type of section (`header` or `footer`)
	///   - section: destination section of the table
	open func configure(_ view: UITableViewHeaderFooterView, type: SectionType, section: Int) {
		(view as? View)?.configure(self.item, type: type, section: section)
	}
	
	/// Initialize a new section view
	///
	/// - Parameters:
	///   - item: item represented by the section
	///   - configurator: configuration callback called just after the init
	public init(_ item: View.T, _ configurator: SectionViewConfigurator? = nil) {
		self.item = item
		configurator?(self)
	}
	
}

public protocol DeclarativeView {
	
	associatedtype T
	
	/// Reuse identifier
	static var reuseIdentifier: String { get }

	/// Estimated height return `nil` by default
	static var estimatedHeight: CGFloat? { get }
	
	/// Default height return `nil` by default
	static var defaultHeight: CGFloat? { get }
	
	/// Configure section
	///
	/// - Parameters:
	///   - view: view instance to configure
	///   - type: type of section
	///   - section: section index
	func configure(_ item: T, type: SectionType, section: Int)

}

public protocol SectionProtocol {
	
	typealias SectionInfo = (_: UITableViewHeaderFooterView?,_: SectionType, _: Int)
	typealias SectionEventCallback = ((SectionInfo) -> (Void))
	
	/// Reuse identifier of the section
	var reuseIdentifier:	String { get }
	
	/// Class type of the section's view
	var viewType:			AnyClass { get }
	
	/// Evaluation function to estimate the view's height
	var evaluateEstimatedHeight: ((SectionType) -> (CGFloat?))? { get set }

	/// Evaluation function to get the view's height
	var evaluateViewHeight: ((SectionType) -> (CGFloat?))? { get set }

	/// Provide static implementation of the estimated height for a table's section
	var estimatedHeight: CGFloat? { get }
	
	/// Provide static implementation of the height for a table's section
	var defaultHeight: CGFloat? { get }
	
	/// Hash value
	var hashValue: Int { get }

	/// Configure section
	///
	/// - Parameters:
	///   - view: view instance to configure
	///   - type: type of section
	///   - section: section index
	func configure(_ view: UITableViewHeaderFooterView, type: SectionType, section: Int)
	
	/// Event called just after a dequeue of a section view
	var onDequeue: SectionEventCallback? { get set }

	/// Event called when a section's view is about to be displayed into the table
	var onWillDisplay: SectionEventCallback? { get set }

	/// Event called when a section did removed for a table
	var didEndDisplaying: SectionEventCallback? { get set }

}

public extension DeclarativeView where Self: UITableViewHeaderFooterView {

	/// Default implementation return the same name of the subclass you are using
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	/// Estimated height return `nil` by default
	static var estimatedHeight: CGFloat? {
		return nil
	}

	/// Default height return `nil` by default
	static var defaultHeight: CGFloat? {
		return nil
	}

}
