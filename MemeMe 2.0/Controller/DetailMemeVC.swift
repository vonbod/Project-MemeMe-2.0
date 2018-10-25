//
//  DetailMemeVC.swift
//  MemeMe 2.0
//
//  Created by Enno von Bodecker on 23.10.18.
//  Copyright © 2018 EvB. All rights reserved.
//

import Foundation
import UIKit

class DetailMemeVC: UIViewController {
	//MARK: Properties and variables
	var memeData: MemeData!
	
	//MARK: IBOutlets
	@IBOutlet weak var imageView: UIImageView!
	
	//MARK: IBActions
	@IBAction func dismissDetailVC(_ sender: Any) {
			self.dismiss(animated: true, completion: nil)
	}
	
	//MARK: Overrides methods
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.imageView!.image = memeData.memedImage
	}
}

