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

open class CollectionManager: NSObject,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
	
	/// Define the cell size.
	///
	/// - `default`: standard behaviour (no auto sizing, needs to implement `onGetItemSize` on adapters).
	/// - automatic: set the estimatedSize of the layout to `UICollectionViewFlowLayoutAutomaticSize` for using autolayout to determine the size
	/// - estimated: provide an estimated cell size which can improve the performance of the collection view when the cells adjust their size dynamically.
	///				 causes the collection view to query each cell for its actual size using the cell’s preferredLayoutAttributesFitting(_:) method.
	/// - fixed: fixed size where each item has the same size
	public enum CellSize {
		case `default`
		case automatic
		case estimated(_: CGSize)
		case fixed(_: CGSize)
	}
	
	//MARK: PUBLIC PROPERTIES
	
	/// Managed collection view
	public private(set) weak var collection: UICollectionView?
	
	/// Registered adapters for this collection manager
	public private(set) var adapters: [String: AbstractAdapterProtocol] = [:]
	
	/// Registered cell, header/footer identifiers for given collection view.
	public private(set) var reusableRegister: CollectionReusableRegister
	
	/// Drag & Drop Event Manager
	/// Its valid only if `dragDropEnabled` is `true`.
	public private(set) var dragDrop: DragAndDropManager? = nil
	
	/// Enable or disable drag&drop on collection view.
	/// You must configure the `dragDrop` manager if you enabled this feature.
	public var dragDropEnabled: Bool {
		set {
			switch newValue {
			case true: 	self.dragDrop = DragAndDropManager(manager: self)
			case false: self.dragDrop = nil
			}
		}
		get { return (self.dragDrop != nil) }
	}
	
	/// Set it to `true` to enable cell prefetching. By default is set to `false`.
	public var prefetchEnabled: Bool {
		set {
			switch newValue {
			case true: self.collection!.prefetchDataSource = self
			case false: self.collection!.prefetchDataSource = nil
			}
		}
		get {
			return (self.collection!.prefetchDataSource != nil)
		}
	}

	/// Sections of the collection
	public private(set) var sections: [CollectionSection] = []
	
	//MARK: PUBLIC EVENTS
	
	/// Asks for the custom transition layout to use when moving between the specified layouts.
	/// Implement this method if you want to return a custom UICollectionViewTransitionLayout object for use during the transition.
	/// A transition layout object lets you customize the behavior of cells and decoration views when transitioning from one layout to the next.
	/// Normally, transitioning between layouts causes items to animate directly from their current locations to their new locations.
	/// With a transition layout object, you can have objects follow a non linear path, use a different timing algorithm, or move according to incoming touch events.
	public var onLayoutDidChange: ((_ old: UICollectionViewLayout, _ new: UICollectionViewLayout) -> UICollectionViewTransitionLayout)? = nil
	
	/// Gives the  opportunity to customize the content offset for layout changes and animated updates.
	/// Event will receive the proposed point (in the coordinate space of the collection view’s content view) for the upper-left corner of the visible content.
	/// This represents the point that the collection view has calculated as the most likely value to use for the animations or layout update.
	/// Returned value is the content offset that you want to use instead.
	///
	/// If you do not implement this method, the collection view uses the value in the proposedContentOffset parameter.
	public var onTargetOffset: ((_ proposedContentOffset: CGPoint) -> CGPoint)? = nil
	
	/// Asks the delegate for the index path to use when moving an item.
	/// During the interactive moving of an item, the collection view calls this method to see if you want to provide a different index path
	/// than the proposed path.
	/// You might use this method to prevent the user from dropping the item in an invalid location.
	/// For example, you might prevent the user from dropping the item in a specific section.
	///
	/// If you do not implement this method, the collection view uses the index path in the proposedIndexPath parameter.
	public var onMoveItemPath: ((_ originalIndexPath: IndexPath, _ proposedIndexPath: IndexPath) -> IndexPath)? = nil
	
	/// Asks the delegate whether a change in focus should occur.
	/// Before a focus change can occur, the focus engine asks all affected views if such a change should occur.
	/// In response, the collection view calls this method to give you the opportunity to allow or prevent the change.
	/// Return this method to prevent changes that should not occur.
	/// For example, you might use it to ensure that the navigation between cells occurs in a specific order.
	///
	/// If you do not implement this method, the collection view assumes a return value of true.
	public var onShouldUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext) -> Bool)? = nil
	
	/// Tells that a focus update occurred.
	/// The collection view calls this method when a focus-related change occurs.
	/// You can use this method to update your app’s state information or to animate changes to your app’s visual appearance.
	public var onDidUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator) -> Void)? = nil
	
	/// Internal representation of the cell size
	private var _cellSize: CellSize = .default

	/// Define the size of the items into the cell (valid with `UICollectionViewFlowLayout` layout).
	public var cellSize: CellSize {
		set {
			guard let layout = self.collection?.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			self._cellSize = newValue
			switch _cellSize {
			case .automatic:
				layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
				layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
			case .estimated(let estimateSize):
				layout.estimatedItemSize = estimateSize
				layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
			case .fixed(let fixedSize):
				layout.estimatedItemSize = .zero
				layout.itemSize = fixedSize
			case .default:
				layout.estimatedItemSize = .zero
				layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
			}
		}
		get {
			return _cellSize
		}
	}
	
	/// Initialize a new collection manager with given collection instance.
	///
	/// - Parameter collection: instance of the collection to manage.
	public init(_ collection: UICollectionView) {
		self.reusableRegister = CollectionReusableRegister(collection)
		super.init()
		self.collection = collection
		self.collection?.dataSource = self
		self.collection?.delegate = self
		self.collection?.dragDelegate = self.dragDrop
		self.collection?.dropDelegate = self.dragDrop
	}
	
	//MARK: Public Methods
	
	/// Return item at path.
	///
	/// - Parameters:
	///   - indexPath: index path to retrive
	///   - safe: `true` to return nil if path is invalid, `false` to perform an unchecked retrive.
	/// - Returns: model
	public func item(at indexPath: IndexPath, safe: Bool = true) -> ModelProtocol? {
		guard safe else { return self.sections[indexPath.section].items[indexPath.item] }
		
		guard indexPath.section < self.sections.count else { return nil }
		let section = self.sections[indexPath.section]
		
		guard indexPath.item < section.items.count else { return nil }
		return section.items[indexPath.item]
	}
	
	/// Reload collection.
	///
	/// - Parameter after: 	if defined a block animation is performed considering changes applied to the model;
	///						if `nil` reload is performed without animation.
	public func reloadData(after task: (() -> (Void))? = nil, onEnd: (() -> (Void))? = nil) {
		guard let task = task else {
			self.collection?.reloadData()
			onEnd?()
			return
		}
		
		// Keep a reference to removed items in order to perform diff and animation
		let oldSections: [CollectionSection] = Array.init(self.sections)
		var oldItemsInSections: [String: [ModelProtocol]] = [:]
		self.sections.forEach { oldItemsInSections[$0.UUID] = Array($0.items) }
		
		// Execute block for changes
		task()
		
		// Evaluate changes in sections
		let sectionChanges = SectionChanges.create(oldSections: oldSections, newSections: self.sections)

		self.collection?.performBatchUpdates({
			sectionChanges.applyChangesIfNeeded(collection: self.collection)
			
			// For any remaining active section evaluate changes inside
			self.sections.enumerated().forEach { (idx,newSection) in
				if let oldSectionItems = oldItemsInSections[newSection.UUID] {
					let diffData = diff(old: (oldSectionItems as! [AnyHashable]), new: (newSection.items as! [AnyHashable]))
					let itemChanges = SectionItemsChanges.create(fromChanges: diffData, section: idx)
					itemChanges.applyChangesToSectionItems(of: collection)
				}
			}
			
		}, completion: { end in
			if end { onEnd?() }
		})
	}
	
	
	/// Register an adapter.
	/// An adapter is an object which manage a pair of `ModelProtocol`, `CellProtocol` types which defines
	/// a type of data inside the collection (all models of the given type are managed by given cell type).
	/// This is used to ensure type safety of the data and its the core of the library itself.
	/// Be sure to register all required adapters before using the collection itself.
	///
	/// - Parameter adapter: adapter to register
	public func register(adapter: AbstractAdapterProtocol) {
		let modelID = String(describing: adapter.modelType)
		self.adapters[modelID] = adapter // register adapter
		self.reusableRegister.registerCell(forAdapter: adapter) // register associated cell types into the collection
	}
	
	//MARK: Manage Content
	
	/// Create a new section, append it at the end of the sections list and insert in it passed models.
	///
	/// - Parameter items: items of the section
	/// - Returns: added section instance
	@discardableResult
	public func add(items: [ModelProtocol]) -> CollectionSection {
		let section = CollectionSection(items)
		self.sections.append(section)
		return section
	}
	
	/// Add a new section at given index.
	///
	/// - Parameters:
	///   - section: section to insert.
	///   - index: destination index; if `nil` it will be append at the end of the list.
	public func add(_ section: CollectionSection, at index: Int? = nil) {
		guard let i = index else {
			self.sections.append(section)
			return
		}
		self.sections.insert(section, at: i)
	}
	
	/// Add a list of the section starting at given index.
	///
	/// - Parameters:
	///   - sections: sections to append
	///   - index: destination index; if `nil` it will be append at the end of the list.
	public func add(_ sections: [CollectionSection], at index: Int? = nil) {
		guard let i = index else {
			self.sections.append(contentsOf: sections)
			return
		}
		self.sections.insert(contentsOf: sections, at: i)
	}
	
	/// Remove all sections from the collection.
	///
	/// - Returns: number of removed sections.
	@discardableResult
	public func removeAll() -> Int {
		let count = self.sections.count
		self.sections.removeAll()
		return count
	}
	
	/// Remove section at index from the collection.
	/// If index is not valid it does nothing.
	///
	/// - Parameter index: index of the section to remove.
	/// - Returns: removed section
	@discardableResult
	public func remove(at index: Int) -> CollectionSection? {
		guard index < self.sections.count else { return nil }
		return self.sections.remove(at: index)
	}
	
	/// Remove sections at given indexes.
	/// Invalid indexes are ignored.
	///
	/// - Parameter indexes: indexes to remove.
	/// - Returns: removed sections.
	@discardableResult
	public func remove(at indexes: IndexSet) -> [CollectionSection] {
		var removed: [CollectionSection] = []
		indexes.reversed().forEach {
			if $0 < self.sections.count {
				removed.append(self.sections.remove(at: $0))
			}
		}
		return removed
	}
	
	//MARK: Helper Internal Methods
	
	/// Return the context for an element at given index.
	/// It returns the instance of the model and the registered adapter used to represent it.
	///
	/// - Parameter index: index path of the item.
	/// - Returns: context
	internal func context(forItemAt index: IndexPath) -> (ModelProtocol,AbstractAdapterProtocolFunctions) {
		let item: ModelProtocol = self.sections[index.section].items[index.row]
		let modelID = String(describing: type(of: item.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an dap")
		}
		return (item,adapter as! AbstractAdapterProtocolFunctions)
	}

	internal func context(forModel model: ModelProtocol) -> AbstractAdapterProtocolFunctions {
		let modelID = String(describing: type(of: item.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an dap")
		}
		return (adapter as! AbstractAdapterProtocolFunctions)
	}
	
	internal func adapters(forIndexPath paths: [IndexPath]) -> [PrefetchModelsGroup] {
		var list: [String: PrefetchModelsGroup] = [:]
		paths.forEach { indexPath in
			let model = self.sections[indexPath.section].items[indexPath.item]
			let modelID = String(describing: type(of: model.self))
			
			var context: PrefetchModelsGroup? = list[modelID]
			if context == nil {
				context = PrefetchModelsGroup(adapter: self.adapters[modelID] as! AbstractAdapterProtocolFunctions)
				list[modelID] = context
			}
			context!.models.append(model)
			context!.indexPaths.append(indexPath)
		}
		
		return Array(list.values)
	}
}

//MARK: CollectionManager UICollectionViewDataSource Protocol Implementation

public extension CollectionManager {
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.sections.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.sections[section].items.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let (model,adapter) = self.context(forItemAt: indexPath)
		let cell = adapter._instanceCell(in: collectionView, at: indexPath)
		adapter._onDequeue(model: model, cell: cell, path: indexPath, collection: collectionView)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._willDisplay(model: model, cell: cell, path: indexPath, collection: collectionView)
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.adapters.forEach { data in
			(data.value as! AbstractAdapterProtocolFunctions)._didEndDisplay(cell: cell, path: indexPath, collection: collectionView)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didSelect(model: model, cell: nil, path: indexPath, collection: collectionView)
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didDeselect(model: model, cell: nil, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldSelect(model: model, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldDeSelect(model: model, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldHighlight(model: model, path: indexPath, collection: collectionView)
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didHighlight(model: model, cell: nil, path: indexPath, collection: collectionView)
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._didUnHighlight(model: model, cell: nil, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
		guard let transitionLayout = self.onLayoutDidChange?(fromLayout,toLayout) else {
			return UICollectionViewTransitionLayout.init(currentLayout: fromLayout, nextLayout: toLayout)
		}
		return transitionLayout
	}
	
	public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		guard let overrideIndexPath = self.onMoveItemPath?(originalIndexPath, proposedIndexPath) else {
			return proposedIndexPath
		}
		return overrideIndexPath
	}
	
	public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		guard let overridePoint = self.onTargetOffset?(proposedContentOffset) else {
			return proposedContentOffset
		}
		return overridePoint
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldShowEditMenu(model: model, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canPerformEditMenuAction(model: model, path: indexPath, collection: collectionView, selector: action, sender: sender)
	}
	
	public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		let (model,adapter) = self.context(forItemAt: indexPath)
		adapter._performEditMenuAction(model: model, path: indexPath, collection: collectionView, selector: action, sender: sender)
	}
	
	public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._canFocusItem(model: model, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
		let (model,adapter) = self.context(forItemAt: indexPath)
		return adapter._shouldSpringLoadItem(model: model, path: indexPath, collection: collectionView)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
		guard let update = self.onShouldUpdateFocus?(context) else {
			return true
		}
		return update
	}
	
	public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		self.onDidUpdateFocus?(context,coordinator)
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let section = sections[indexPath.section]
		
		var identifier: String!
		
		switch kind {
		case UICollectionElementKindSectionHeader:
			guard let header = section.header else { return UICollectionReusableView() }
			identifier = self.reusableRegister.registerHeaderFooter(header, type: kind)
			
		case UICollectionElementKindSectionFooter:
			guard let footer = section.footer else { return UICollectionReusableView() }
			identifier = self.reusableRegister.registerHeaderFooter(footer, type: kind)
			
		default:
			return UICollectionReusableView()
		}
		
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
	
		return view
	}
	
	public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		
		switch elementKind {
		case UICollectionElementKindSectionHeader:
			self.sections[indexPath.section].header?._didDisplay(view: view, section: indexPath.section, collection: collectionView)
		case UICollectionElementKindSectionFooter:
			self.sections[indexPath.section].footer?._didDisplay(view: view, section: indexPath.section, collection: collectionView)
		default:
			break
		}
		view.layer.zPosition = 0
	}
	
	//MARK: Prefetching
	
	internal class PrefetchModelsGroup {
		let adapter: 	AbstractAdapterProtocolFunctions
		var models: 	[ModelProtocol] = []
		var indexPaths: [IndexPath] = []
		
		public init(adapter: AbstractAdapterProtocolFunctions) {
			self.adapter = adapter
		}
	}
	
	
	public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPath: indexPaths).forEach { adapterGroup in
			adapterGroup.adapter._didPrefetchItems(models: adapterGroup.models, indexPaths: adapterGroup.indexPaths, collection: collectionView)
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		self.adapters(forIndexPath: indexPaths).forEach { adapterGroup in
			adapterGroup.adapter._didCancelPrefetchItems(models: adapterGroup.models, indexPaths: adapterGroup.indexPaths, collection: collectionView)
		}
	}
	
}
