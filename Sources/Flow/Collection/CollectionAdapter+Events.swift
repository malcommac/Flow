//
//  CollectionAdapter+Events.swift
//  Flow
//
//  Created by Daniele Margutti on 18/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public extension CollectionAdapter {

	public enum Event<M,C>: CollectionAdapterEventable {
		case dequeue(_: ((_ ctx: Context<M,C>) -> Void))
		case shouldSelect(_: ((_ ctx: Context<M,C>) -> Bool))
		case shouldDeselect(_: ((_ ctx: Context<M,C>) -> Bool))
		case didSelect(_: ((_ ctx: Context<M,C>) -> Void))
		case didDeselect(_: ((_ ctx: Context<M,C>) -> Void))
		case didHighlight(_: ((_ ctx: Context<M,C>) -> Void))
		case didUnhighlight(_: ((_ ctx: Context<M,C>) -> Void))
		case shouldHighlight(_: ((_ ctx: Context<M,C>) -> Bool))
		case willDisplay(_: ((_ ctx: Context<M,C>) -> Void))
		case endDisplay(_: ((_ cell: C, _ path: IndexPath) -> Void))
		case shouldShowEditMenu(_: ((_ ctx: Context<M,C>) -> Bool))
		case canPerformEditAction(_: ((_ ctx: Context<M,C>) -> Bool))
		case performEditAction(_: ((_ ctx: Context<M,C>, _ selector: Selector, _ sender: Any?) -> Void))
		case canFocus(_: ((_ ctx: Context<M,C>) -> Bool))
		case itemSize(_: ((_ ctx: Context<M,C>) -> CGSize))
		case generateDragPreview(_: ((_ ctx: Context<M,C>) -> UIDragPreviewParameters?))
		case generateDropPreview(_: ((_ ctx: Context<M,C>) -> UIDragPreviewParameters?))
		case prefetch(_: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> Void))
		case cancelPrefetch(_: ((_ items: [M], _ paths: [IndexPath], _ collection: UICollectionView) -> Void))
		case shouldSpringLoad(_: ((_ ctx: Context<M,C>) -> Bool))
		
		var name: CollectionAdapterEventKey {
			switch self {
			case .dequeue:				return .dequeue
			case .shouldSelect:			return .shouldSelect
			case .shouldDeselect:		return .shouldDeselect
			case .didSelect:			return .didSelect
			case .didDeselect:			return .didDeselect
			case .didHighlight:			return .didHighlight
			case .didUnhighlight:		return .didUnhighlight
			case .shouldHighlight:		return .shouldHighlight
			case .willDisplay:			return .willDisplay
			case .endDisplay:			return .endDisplay
			case .shouldShowEditMenu:	return .shouldShowEditMenu
			case .performEditAction:	return .performEditAction
			case .canFocus:				return .canFocus
			case .itemSize:				return .itemSize
			case .generateDragPreview:	return .generateDragPreview
			case .generateDropPreview:	return .generateDropPreview
			case .prefetch:				return .prefetch
			case .cancelPrefetch:		return .cancelPrefetch
			case .canPerformEditAction:	return .canPerformEditAction
			case .shouldSpringLoad:		return .shouldSpringLoad
			}
		}

	}
	
}

internal protocol CollectionAdapterEventable {
	var name: CollectionAdapterEventKey { get }
}

internal enum CollectionAdapterEventKey: String {
	case dequeue
	case shouldSelect
	case shouldDeselect
	case didSelect
	case didDeselect
	case didHighlight
	case didUnhighlight
	case shouldHighlight
	case willDisplay
	case endDisplay
	case shouldShowEditMenu
	case performEditAction
	case canPerformEditAction
	case canFocus
	case itemSize
	case generateDragPreview
	case generateDropPreview
	case prefetch
	case cancelPrefetch
	case shouldSpringLoad
}

// Collection Section Events

public extension CollectionDirector {
	
	public enum Event: CollectionSectionAdapterEventable {
		case layoutDidChange(_: ((_ old: UICollectionViewLayout, _ new: UICollectionViewLayout) -> UICollectionViewTransitionLayout))
		case targetOffset(_: ((_ proposedContentOffset: CGPoint) -> CGPoint))
		case moveItemPath(_: ((_ originalIndexPath: IndexPath, _ proposedIndexPath: IndexPath) -> IndexPath))
		case shouldUpdateFocus(_: ((_ context: UICollectionViewFocusUpdateContext) -> Bool))
		case didUpdateFocus(_: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator) -> Void))
		
		var name: CollectionSectionAdapterEventKey {
			switch self {
			case .layoutDidChange: 		return .layoutDidChange
			case .targetOffset: 		return .targetOffset
			case .moveItemPath: 		return .moveItemPath
			case .shouldUpdateFocus: 	return .shouldUpdateFocus
			case .didUpdateFocus: 		return .didUpdateFocus
			}
		}
	}
	
}

internal protocol CollectionSectionAdapterEventable {
	var name: CollectionSectionAdapterEventKey { get }
}

internal enum CollectionSectionAdapterEventKey: String {
	case layoutDidChange
	case targetOffset
	case moveItemPath
	case shouldUpdateFocus
	case didUpdateFocus
}

