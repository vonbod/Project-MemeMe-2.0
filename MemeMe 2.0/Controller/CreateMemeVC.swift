//
//  ViewController.swift
//  4.0 Meme Me Experiments
//
//  Created by Enno von Bodecker on 29.09.18.
//  Copyright © 2018 EvB. All rights reserved.
//

import UIKit

//MARK: Struct for all the Memedata
struct MemeData {   // Struct that holds the memeData
	let textTop : String?
	let textBottom : String?
	let originalImage : UIImage?
	let memedImage : UIImage?
}

//MARK: Trying to solve the misplacing of the labels landscape/portrait modes
// For future use
struct DeviceInfo {
	
	struct Orientation {
		// indicate current device is in the LandScape orientation
		static var isLandscape: Bool {
			get {
				return UIDevice.current.orientation.isValidInterfaceOrientation
					? UIDevice.current.orientation.isLandscape
					: UIApplication.shared.statusBarOrientation.isLandscape
			}
		}
		// indicate current device is in the Portrait orientation
		static var isPortrait: Bool {
			get {
				return UIDevice.current.orientation.isValidInterfaceOrientation
					? UIDevice.current.orientation.isPortrait
					: UIApplication.shared.statusBarOrientation.isPortrait
			}
		}
	}
	
	// Which type of device is the user using?
	struct DeviceType {
		static var type: String {
			get {
				switch UIDevice.current.userInterfaceIdiom {
					case .phone:
						return "iPhone"
					case .pad:
						return "iPad"
					case .tv:
						return "Tv"
					case .carPlay:
						return "carPlay"
					case .unspecified:
						return "unspecified"
				}
			}
		}
	}
}

class CreateMemeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
	// TextField Properties(styles): Dictionary for Textformat
	let memeTextAttributes:[NSAttributedString.Key: Any] = [
		NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black,
		NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white,
		NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -2.0]

	// MARK: OUTLETS Config
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var textOne: UITextField!
	@IBOutlet weak var textTwo: UITextField!
	@IBOutlet weak var camaraButton: UIBarButtonItem!
	@IBOutlet weak var topToolbar: UIToolbar!
	@IBOutlet weak var bottomToolbar: UIToolbar!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	
	// Not needed anymore since UITextField Delegate has been moved to this class and is not external anymore.
	// MARK: DELEGATE External delegate for textfields
	//let memeTextFieldsDelegate = MemeTextFieldsDelegate()
	
	// MARK: OVERRIDE Functions
	override func viewDidLoad() {
		super.viewDidLoad()
		//Configure the nessesary properties of the textFields
		self.configureUI()
		
		// Check if the device the App is running on has a camara and enable/disable the toolbar Button accordingly
		let hasCamara = UIImagePickerController.isSourceTypeAvailable(.camera)
		self.camaraButton.isEnabled = hasCamara
	}
	
	//MARK: ViewWillAppear()
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.subscribeToKeyboardNotifications()
	}
	
	//Mark: ViewWillDisappear()
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.unsubscribeFromKeyboardNotifications()
	}
	
	//MARK: UITextFieldDelegate Methods
	// Prepare textField for new entry
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = ""
		textField.placeholder = ""
		textField.becomeFirstResponder()  /* Keyboard: Works with and without this line */
	}
	
	// What happens when you press Enter:
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == textOne {
			textOne.resignFirstResponder()
			textTwo.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}
	
	// MARK: Configure UserInterface */
	func configureUI() {
		// Setting text value here can also be done in Storyboard with placeholder property.
		self.textOne.text = "TOP"
		self.textTwo.text = "BOTTOM"
		self.textOne.isHidden = false
		self.textTwo.isHidden = false
		//print("Type: \(DeviceInfo.DeviceType.type)")
		
		// Call method to set styles for textFields
		setTextFieldProperties(toTextField: textOne)
		setTextFieldProperties(toTextField: textTwo)
		
		self.shareButton.isEnabled = false
	}

	// Layout styles for the textfields used in the Meme
	func setTextFieldProperties(toTextField textField: UITextField) {
		textField.defaultTextAttributes = memeTextAttributes
		textField.textAlignment = .center
		textField.autocapitalizationType = .allCharacters
		textField.delegate = self
		
		/*  Open question since MemeMe 1.0
			Comment to tutor: textField.autocapitalizationType = .allCharacters doesn't work on
			iPpad,why?
		*/
	}
	
	// imagePickerController: User selected picture
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		// UIImagePickerController.InfoKey.originalImage contains image selected by the picker
		if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			self.imagePickerView.contentMode = .scaleAspectFit //Image scaling
			self.imagePickerView.image = selectedImage
			
			// After chosing the picker can be removed to display the image
			dismissForm()
			// when imagePickerView has an image we can enable the share buttom
			self.shareButton.isEnabled = true
		}
	}
	
	// imagePickerControllerDidCancel: Dismiss Picker, it was canceled by the user
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismissForm()
	}
	
	// To avoid identical code in varios places.
	func dismissForm() {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: generateMemedImage() & SAVE
	/* Generate the memData that ca be saved */
	func generateMemedImage() -> UIImage {  /* Provide by UDACITY */

		// hide the toolbars so we don't see them in the picture
		self.hideToolBars(toHide: true)
		
		// Render view to an image
		UIGraphicsBeginImageContext(self.view.frame.size) //maybe: self.imagePickerView.frame.size make a smaller picture
		view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
		let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		// unhide the toolbars to use the App
		self.hideToolBars(toHide: false)

		return memedImage
	}
	
	// Hide the Tool and Navigation bars
	func hideToolBars(toHide hide: Bool) {
		if hide {
			self.topToolbar.isHidden = true
			self.bottomToolbar.isHidden = true
			//self.view.backgroundColor = UIColor.white // Otherwise the picture has a black background.
		} else {
			self.view.backgroundColor = UIColor.black
			self.topToolbar.isHidden = false
			//self .bottomToolbar.isHidden = false
		}
	}
	
	//MARK: Notification subscriptions
	func subscribeToKeyboardNotifications() {
		// Subscribe to KeyboardWillShow Notification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		// Subscribe to KeyboardWillHide Notification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		// Unsubscribe to KeyboardWillShow Notification
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		// Unsubscribe to KeyboardWillShow Notification
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWillShow(_ notification: Notification) {
		if self.textTwo.isEditing {  /* only shift keyboard for Bottom text */
			self.view.frame.origin.y -= getKeyboardHeight(notification)
		}
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		if self.textTwo.isEditing {  /* only shift keyboard for Bottom text */
			self.view.frame.origin.y += getKeyboardHeight(notification)
		} /* else  if textOne.isEditing {  // How can I set the focus to the Bottom when done with Top?
			textTwo.becomeFirstResponder() /* Set focus to Bottom Text */
		} */
	}
	
	func getKeyboardHeight(_ notification: Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.cgRectValue.height
	}
	
	// MARK: IBAction for Image from Library
	@IBAction func pickAnImageFromAlbum(_ sender: Any) {  /* Image from Library */
		openImagePicker(.photoLibrary)
		/* Note to myself:
			SET NSPhotoLibraryUsageDescription:
			“Privacy - Photo Library Usage Description” in Info.plist
		*/
	}

	@IBAction func pickImageFromCamara(_ sender: Any) {   /* Image from Camera */
		openImagePicker(.camera)
		/* Note to myself:
			SET NSCameraUsageDescription:
			“Privacy - Camera Usage Description” in Info.plist
		*/
	}
	
	//MARK: openImagePicker from different sources: .camera, .library
	func openImagePicker(_ type: UIImagePickerController.SourceType){
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = type
		present(imagePicker, animated: true, completion: nil)
	}
	
	
	// Share the meme and save it.
	@IBAction func shareMeme(_ sender: Any) {
		let memedImage = generateMemedImage()
		let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

		// On iPad UIActivityViewController is presented with a popover
		controller.popoverPresentationController?.sourceView = self.view
		//controller.popoverPresentationController?.sourceRect = topToolbar.barPosition
		
		self.present(controller, animated: true, completion: nil )
		controller.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> Void in
			if (completed) {
				//for i in 1...15 {  // Testingloop creates a table full of Memes
					self.saveMeme(memedImage: memedImage)
				//}
				self.dismissForm()
			} else {
				// Reason: Could be canceld
			}
		}
	}

	// Save the image
	func saveMeme(memedImage: UIImage) {
		let meme = MemeData(textTop: textOne.text, textBottom: textTwo.text, originalImage: imagePickerView.image, memedImage: memedImage)
		// #MemeMe 2.0 Addons###
		let object = UIApplication.shared.delegate
		let appDelegate = object as! AppDelegate
		appDelegate.memes.append(meme)
	}
	
	@IBAction func cancelApp(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
		//		self.imagePickerView.image = nil
		//		self.configureUI()
	}
}
