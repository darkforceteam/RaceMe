//
//  AddGroupViewController.swift
//  RaceMe
//
//  Created by Luu Tien Thanh on 4/8/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import WDImagePicker

class AddGroupViewController: UIViewController {
    @IBOutlet weak var imagePlaceholderView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var uploadImageButton: UIButton!
    
    var imagePicker: WDImagePicker!
    var group: Group!
    var bannerImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Add New"

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(AddGroupViewController.saveGroup))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddGroupViewController: WDImagePickerDelegate {
    func saveGroup() {
        if let nameField = nameTextField.text, let descField = descTextField.text, !nameField.isEmpty && !descField.isEmpty {
            if let uploadData = UIImagePNGRepresentation(bannerImage) {
                let imageName = NSUUID().uuidString
                FIRStorage.storage().reference().child("group_banners").child("\(imageName).png").put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    self.group = Group.init(name: self.nameTextField.text!, description: self.descTextField.text!, banner: (metadata?.downloadURL()?.absoluteString)!)
                    FIRDatabase.database().reference().child("GROUPS").childByAutoId().setValue(self.group.toAnyObject())
                })
            }
            _ = navigationController?.popToRootViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: "Missing Required Field", message: "Name & Description cannot be empty", preferredStyle: .alert)
            let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OkAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func uploadImage(_ sender: UIButton) {
        imagePicker = WDImagePicker()
        imagePicker.cropSize = CGSize(width: 310, height: 150)
        imagePicker.delegate = self
        
        present(imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage) {
        bannerImage = resizeImage(image: pickedImage, targetSize: CGSize(width: 640, height: 300))
        uploadImageButton.setImage(bannerImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidCancel(_ imagePicker: WDImagePicker) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
