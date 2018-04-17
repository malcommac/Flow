//
//  ViewController.swift
//  FlowTestApp
//
//  Created by danielemargutti on 09/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import UIKit

func generateRandomColor() -> UIColor {
	let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
	let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
	let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
	
	return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
}

class ViewController: UIViewController {
	
	@IBOutlet public var collectionView: UICollectionView?
	
	private var manager: FlowCollectionDirector?
	
	public lazy var usersList: [UserModel] = {
		let number: Int = 150
		var l: [UserModel] = []
		for i in 0..<number {
			l.append(UserModel.init(String.randomAlphaNumericString(length: 10)))
		}
		return l
	}()
	

	func generateRandomColor() -> UIColor {
		let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
		let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
		let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
	}
	
	@objc func test() {
		self.manager?.reloadData(after: { [weak self] in

		//	self?.manager?.sections.first!.add(UserModel.init("ZIO PRIMO!"), at: 0)

		//	let s2 = CollectionSection([UserModel.init("bella")])
		//	self?.manager?.add(s2, at: 0)
		//	self?.manager!.sections.first!.remove(at: 0)
			
			self?.manager?.remove(at: 0)
		})
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(test))
		
		print("Generating names...")
		let l = self.usersList
		print("Now loading \(l.count) models")
		
	
		
		
		self.manager = FlowCollectionDirector(self.collectionView!)
		self.manager?.prefetchEnabled = true
		
		let adapterArticle = CollectionAdapter<Article,CellArticle> {
//			$0.onGetItemSize = { context in
//				return CGSize(width: context.collectionSize!.width, height: 50)
//			}
			$0.onConfigure = { context in
				context.cell?.articleTitle?.text = context.model.title
				context.cell?.articleSubtitle?.text = context.model.subtitle
				context.cell?.backgroundColor = (context.indexPath.item % 2 == 0 ? UIColor.gray : UIColor.lightGray)
			}
//			$0.onGetItemSize = { _ in
//				return UICollectionViewFlowLayoutAutomaticSize
//			}
		}
		
	
		
		self.manager?.register(adapter: adapterArticle)
		self.manager?.sectionsInsets = .zero
		self.manager?.itemSize = .estimated(CGSize(width: 1, height: 1))
		
		let section = self.manager?.add(items: [
			Article("titolo","sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo sottotitolo "),
			Article("titolo1","sottotitolo1"),
			Article("titolo2","sottotitolo2"),
			])
		self.manager?.reloadData()

		/*let adUser = CollectionAdapter<UserModel,CellUser> {
			$0.onConfigure = { context in
				context.cell?.nameLabel?.text = context.model.name
				context.cell?.backgroundColor = (context.indexPath.item % 2 == 0 ? UIColor.gray : UIColor.lightGray)
			}
			$0.onGetItemSize = { context in
				return CGSize(width: context.collectionSize!.width, height: 50)
			}
		}
		self.manager?.register(adapter: adUser)
		let section = self.manager?.add(items: l)
		section?.header = CollectionSectionView<UserHeaderView> {
			$0.onConfigure = { context in
				context.view?.label?.text = "SECTION HEADER \(context.section)"
			}
			$0.onGetReferenceSize = { context in
				return CGSize(width: context.collectionSize!.width, height: 150)
			}
			$0.onDidDisplay = { context in
				print("did display header")
			}
		}
		self.manager?.reloadData()
		
		print("Done")*/
		
	}

}

public class CellArticle: UICollectionViewCell {
	@IBOutlet public var articleTitle: UILabel?
	@IBOutlet public var articleSubtitle: UILabel?
	@IBOutlet public var viewWidth: NSLayoutConstraint?

//	public override func awakeFromNib() {
//		super.awakeFromNib()
//		self.contentView.translatesAutoresizingMaskIntoConstraints = false
//		let screenWidth = UIScreen.main.bounds.size.width
//		viewWidth?.constant = screenWidth - (2 * 12)
//	}
	
	public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

		// Specify you want _full width_
		let targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)

		// Calculate the size (height) using Auto Layout
		let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
		let autoLayoutFrame = CGRect(origin: layoutAttributes.frame.origin, size: autoLayoutSize)

		// Assign the new size to the layout attributes
		layoutAttributes.frame = autoLayoutFrame
		return layoutAttributes

	}
}

public class Article: ModelProtocol, Hashable {

	
	public var title: String
	public var subtitle: String
	public var identifier: Int
	
	public init(_ title: String, _ subtitle: String) {
		self.title = title
		self.subtitle = subtitle
		self.identifier = (title + subtitle).hashValue
	}
	
	public static func == (lhs: Article, rhs: Article) -> Bool {
		return lhs.identifier == rhs.identifier
	}
}


public class CellUser: UICollectionViewCell {
	@IBOutlet public var nameLabel: UILabel?
}

public class UserModel: ModelProtocol, CustomStringConvertible, Equatable, Hashable {
	
	public var identifier: Int {
		return name.hashValue
	}
	
	public static func == (lhs: UserModel, rhs: UserModel) -> Bool {
		return lhs.name == rhs.name
	}
	
	public var name: String
	
	public init(_ name: String) {
		self.name = name
	}
	
	public var description: String {
		return self.name
	}
}
