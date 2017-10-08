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

public typealias RowIdentifier = RawRepresentable

extension Sequence {
	func find( predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
		for element in self {
			if try predicate(element) {
				return element
			}
		}
		return nil
	}
}

/// Event generated for each change of the array
public class Event: CustomStringConvertible {
	
	
	/// Type of event
	/// I've used a class instead of an enum because I wanna try to implement auto adjust of the indexes
	/// when apply changes to the table.
	///
	/// - inserted: insertion
	/// - deleted: removal
	/// - updated: update
	public enum Mode {
		case inserted
		case deleted
		case updated
	}
	
	/// Type of the event
	private(set) var type: Event.Mode
	
	/// Involved indexes for operation
	internal(set) var indexes: [Int]
	
	
	/// Initialize a new event
	///
	/// - Parameters:
	///   - type: type of the event
	///   - indexes: involved indexes
	internal init(_ type: Event.Mode, _ indexes: [Int]) {
		self.type = type
		self.indexes = indexes
	}
	
	
	/// Adjust indexes
	///
	/// - Parameter value: value to sum to each index of the array
	public func incrementIndexes(_ value: Int) {
		for idx in 0..<indexes.count {
			self.indexes[idx] = self.indexes[idx] + value
		}
	}
	
	/// Description of the event
	public var description: String {
		switch self.type {
		case .inserted:		return "Inserted: \(self.indexes)"
		case .deleted:		return "Deleted: \(self.indexes)"
		case .updated:		return "Updated: \(self.indexes)"
		}
	}
}


/// Array observer class
/// This is a simple proxy class which implement an internal array and allows to receive
/// notifications about added/removed/updated objects into the array
public class ArrayObserver {
	
	/// Observer callback
	/// It's a tuple with `all` (array of events since the observer starts observing)
	/// and `new` (events for the last change)
	public typealias ArrayEventCallback = ((_ all: [Event], _ new: [Event]) -> (Bool))
	
	/// All recorded events for this observer
	internal(set) var events: [Event] = []

	/// Identifier of the observer
	internal(set) var UUID: String = NSUUID().uuidString

	/// Handler to call on a new change
	private(set) var handler: ArrayEventCallback? = nil
	
	
	/// Initialize a new observer with a callback which is called when a new update occour.
	///
	/// - Parameter handler: handler
	public init(_ handler: ArrayEventCallback? = nil) {
		self.handler = handler
	}
	
	/// Initialize a new observer with no callback and a fixed ID
	///
	/// - Parameter UUID: identifier
	public init(_ UUID: String) {
		self.handler = nil
		self.UUID = UUID
	}
	
	/// Receive a new set of events from observed array
	///
	/// - Parameters:
	///   - newEvents: events added
	///   - adjust: adjust indexes based upon operations (when a new deletion occour subsequent indexes of the changes
	///             are adjusted automatically by decrementing the value of the removed indexes.
	/// - Returns: `true` to remove observer automatically, `false` to keep it alive
	public func add(newEvents: [Event], adjust: Bool = true) -> Bool {
		if adjust == true {
			newEvents.forEach {
				if $0.type == .deleted {
					for event in events {
						if event.type == .inserted && event.indexes.first! > $0.indexes.first! {
							event.incrementIndexes(-$0.indexes.count)
						}
					}
				}
			}
		}
		self.events.append(contentsOf: newEvents)
		return self.handler?(self.events, newEvents) ?? false
	}
	
}


/// Observerable Array classes
public class ObservableArray<Element>: ExpressibleByArrayLiteral {
	
	/// Elements in array
	internal var elements: [Element]
	
	/// Active observer
	internal(set) var observers: [String: ArrayObserver] = [:]
	
	/// Auto adjust indexes of completed operation when a new set operation arrives
	public var autoAdjustIndexes: Bool = true
	
	public required init() {
		self.elements = []
	}
	
	public var last: Element? {
		return self.elements.count > 0 ? self.elements[self.elements.count - 1] : nil
	}
	
	public init(count: Int, repeatedValue: Element) {
		self.elements = Array(repeating: repeatedValue, count: count)
	}
	
	public required init<S: Sequence>(_ s: S) where S.Iterator.Element == Element {
		self.elements = Array(s)
	}
	
	public required init(arrayLiteral elements: Element...) {
		self.elements = elements
	}
	
	@discardableResult
	public func observe(_ handler: ArrayObserver.ArrayEventCallback? = nil) -> String {
		let observer = ArrayObserver(handler)
		self.observers[observer.UUID] = observer
		return observer.UUID
	}
	
	@discardableResult
	public func observe(_ observer: ArrayObserver) -> String {
		self.observers[observer.UUID] = observer
		return observer.UUID
	}
	
	internal func pushEvents(_ events: [Event]) {
		var toKeep: [String: ArrayObserver] = [:]
		self.observers.enumerated().forEach { _,data in
			if data.value.add(newEvents: events) == false {
				toKeep[data.key] = data.value
			}
		}
		self.observers = toKeep
	}
	
}

extension ObservableArray: Collection {
	
	public var capacity: Int {
		return elements.capacity
	}
	
	public var startIndex: Int {
		return elements.startIndex
	}
	
	public var endIndex: Int {
		return elements.endIndex
	}
	
	public func index(after i: Int) -> Int {
		return self.elements.index(after: i)
	}
	
}

extension  ObservableArray: MutableCollection {
	
	public func reserveCapacity(_ minimumCapacity: Int) {
		return self.elements.reserveCapacity(minimumCapacity)
	}
	
	public func append(_ newElement: Element) {
		self.elements.append(newElement)
		self.pushEvents([Event(.inserted,[elements.count - 1])])
	}
	
	public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
		let end = self.elements.count
		self.elements.append(contentsOf: newElements)
		guard end != self.elements.count else{
			return
		}
		self.pushEvents([Event(.inserted,Array(end..<elements.count))])
	}
	
	public func appendContentsOf<C: Collection>(_ newElements: C) where C.Iterator.Element == Element {
		guard !newElements.isEmpty else {
			return
		}
		let end = elements.count
		elements.append(contentsOf: newElements)
		self.pushEvents([Event(.inserted,Array(end..<elements.count))])
	}
	
	public func removeLast() -> Element {
		let e = elements.removeLast()
		self.pushEvents([Event(.deleted,[elements.count])])
		return e
	}
	
	public func insert(_ newElement: Element, at i: Int) {
		elements.insert(newElement, at: i)
		self.pushEvents([Event(.inserted,[i])])
	}
	
	@discardableResult
	public func remove(at index: Int) -> Element {
		let e = elements.remove(at: index)
		self.pushEvents([Event(.deleted,[index])])
		return e
	}
	
	public func removeAll(_ keepCapacity: Bool = false) {
		guard !elements.isEmpty else { return }
		let es = elements
		elements.removeAll(keepingCapacity: keepCapacity)
		self.pushEvents([Event(.deleted,Array(0..<es.count))])

	}
	
	public func insertContentsOf(_ newElements: [Element], atIndex i: Int) {
		guard !newElements.isEmpty else { return }
		elements.insert(contentsOf: newElements, at: i)
		self.pushEvents([Event(.deleted,Array(i..<i + newElements.count))])
	}
	
	public func popLast() -> Element? {
		let e = elements.popLast()
		if e != nil {
			self.pushEvents([Event(.deleted,[elements.count])])
		}
		return e
	}
	
}

extension ObservableArray: RangeReplaceableCollection {
	
	public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == ObservableArray.Iterator.Element {
		let oldCount = elements.count
		self.elements.replaceSubrange(subrange, with: newElements)
		let first = subrange.lowerBound
		let newCount = elements.count
		let end = first + (newCount - oldCount) + subrange.count
		self.pushEvents([Event(.inserted,Array(first..<end)),
		                 Event(.deleted,Array(subrange.lowerBound..<subrange.upperBound))
		                 ])
	}
	
}

extension ObservableArray: CustomStringConvertible {
	
	public var description: String {
		return elements.description
	}
	
}

extension ObservableArray: CustomDebugStringConvertible {
	
	public var debugDescription: String {
		return elements.debugDescription
	}
	
}


extension ObservableArray: Sequence {
	public subscript(index: Int) -> Element {
		get {
			return elements[index]
		}
		set {
			elements[index] = newValue
			if index == elements.count {
				self.pushEvents([Event(.inserted,[index])])
			} else {
				self.pushEvents([Event(.deleted,[index])])
			}
		}
	}
	public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
		get {
			return elements[bounds]
		}
		set {
			elements[bounds] = newValue
			let first = bounds.lowerBound
			self.pushEvents([
				Event(.inserted,Array(first..<first + newValue.count)),
				Event(.deleted,Array(bounds.lowerBound..<bounds.upperBound))
			])
		}
	}
}
