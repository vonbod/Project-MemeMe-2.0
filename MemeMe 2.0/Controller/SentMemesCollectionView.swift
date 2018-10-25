//
//  SentMemesCollectionView.swift
//  MemeMe 2.0
//
//  Created by Enno von Bodecker on 23.10.18.
//  Copyright © 2018 EvB. All rights reserved.
//

import Foundation
import UIKit

class SentMemesCollectionView: UICollectionViewController {
	
	//MARK: Outlets
	@IBOutlet weak var editButton: UIBarButtonItem!
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	
	//MARK: Variables / Shared Model
	let space: CGFloat = 10.0
	let cellReuseIdentifier = "MemeCollectionViewCell"
	var memeData: [MemeData] {
		return (UIApplication.shared.delegate as! AppDelegate).memes
	}
	/*
		// Can also be declared like this
		var memeData = [MemeData]()
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
	*/

	//MARK: Override methods...
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tabBarController?.tabBar.isHidden = false

		if (memeData.count < 1){ // no data exist
			self.editButton.isEnabled = false
		}
		self.collectionView?.reloadData() // Therre could be a new Meme, reloadData()
	}
	
	// Floelayout for the collection view
	override func viewDidLoad() {
		super.viewDidLoad()
		let divider = getDivider()
		//let dimension = (view.frame.width - (2 * space)) / divider
		let dimension = (view.frame.width - 2 * space) * (divider / 100)
		
		self.flowLayout.minimumInteritemSpacing = space
		self.flowLayout.minimumLineSpacing = space
		self.flowLayout.itemSize = CGSize(width: dimension, height: dimension)
	}
	
	// MARK: DataSource for CollectionViewController
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.memeData.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier, for: indexPath) as! MemeCollectionViewCell
		
		let meme = self.memeData[(indexPath as NSIndexPath).item]
		cell.backgroundView?.contentMode = .scaleAspectFit // Doesnt' also work...
		cell.backgroundView = UIImageView(image: meme.memedImage)
		
		// I couldn't figure out what i needed here, nothing seems to work with cell.memeImage
		//cell.memeImage = UIImage(name: String(meme.memedImage))
		//cell.memeImage = UIImageView(image: meme.memedImage)
		// How can this be done properly? with cell.memeImage
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
		let memeDetailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailMemeVC") as! DetailMemeVC
		let memeDetail = self.memeData[(indexPath as NSIndexPath).row]
		memeDetailVC.memeData = memeDetail
		self.navigationController!.pushViewController(memeDetailVC, animated: true)
		//self.present(memeDetailVC, animated: true, completion: nil)
	}
	
	// Setting the divider different for portrait/landscape
	func getDivider() -> CGFloat {
		if (DeviceInfo.Orientation.isLandscape) {
			print("Device is Landscape")
			return 15.87 //6.3  //Determines the size of the tile in the collectionview
		} else {
			print("Device is Portrait")
			return 22.22 //4.5  //Determines the size of the tile in the collectionview
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		var divider: CGFloat
		divider = getDivider()
		
		//let dimension = (size.width - (2 * space)) / divider
		let dimension = (size.width - 2 * space) * (divider / 100)
		if flowLayout != nil {
			flowLayout.itemSize = CGSize(width: dimension, height: dimension)
		}
	}
	
	@IBAction func createMeme(_ sender: Any) {
		let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorID") as! CreateMemeVC
		self.present(detailController, animated: true, completion: nil)
	}
}
