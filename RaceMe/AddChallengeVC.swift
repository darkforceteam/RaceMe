//
//  AddChallengeVC.swift
//  RaceMe
//
//  Created by LVMBP on 4/11/17.
//  Copyright © 2017 CoderSchool. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import WDImagePicker
class AddChallengeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uploadPhotoBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var groupPick: UITextField!
    @IBOutlet weak var startDatePick: UITextField!
    @IBOutlet weak var endDatePick: UITextField!
    @IBOutlet weak var chalTotLongRunDist: UITextField!
    @IBOutlet weak var chalTotLongRun: UITextField!
    @IBOutlet weak var chalTotWOPick: UITextField!
    @IBOutlet weak var chalToDistPick: UITextField!
    @IBOutlet weak var weekTotWOPick: UITextField!
    @IBOutlet weak var weekTotDistPick: UITextField!
    @IBOutlet weak var weekLongRunPick: UITextField!
    @IBOutlet weak var weekLongRunDistPick: UITextField!
    @IBOutlet weak var woMinDistPick: UITextField!
    @IBOutlet weak var woMinPacePick: UITextField!

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!

    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let dataPicker = UIPickerView()
    var groups = [Group]()
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var chalStorageRef: FIRStorageReference!
    var uploadTask: FIRStorageUploadTask!
    var selectedGroupId: String?
    let fixedData = ["Public","Friends"]
    var startDate: Date?
    var endDate: Date?
    var challenge: Challenge?
    var userId: String?
    var imagePicker: WDImagePicker!
    var chalImg: UIImage?
//    let imagePicker = UIImagePickerController()
    @IBOutlet weak var chalImage: UIImageView!
    @IBOutlet weak var uploadImgProgress: UIProgressView!
    var photoIsUploading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference()
        chalStorageRef = storageRef.child(Constants.STORAGE.CHALLENGE)
        uploadImgProgress.isHidden = true
        loadGroup()
        if challenge == nil{
            deleteBtn.isHidden = true
            createBtn.isEnabled = false
            groupPick.text = fixedData[0]
        } else {
            createBtn.isHidden = true
        }
        createBtn.backgroundColor = UIColor(136, 192, 87)
        createBtn.layer.cornerRadius = 5
//        imagePicker.delegate = self
        dataPicker.delegate = self
        groupPick.inputView = dataPicker
        hideKeyboardWhenTappedAround()
        dateFormatter.dateStyle = .medium
        setupDatePicker()
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        startDatePick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        endDatePick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        chalTotWOPick.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    func textFieldDidChange(textField: UITextField) {
        if nameTextField.text == "" || startDatePick.text == "" || endDatePick.text == "" || chalTotWOPick.text == "" || photoIsUploading{
            //Disable button
            createBtn.isEnabled = false
        } else {
            //Enable button
            createBtn.isEnabled = true
        }
    }
    
    func setupDatePicker(){
        startDate = Date()
        startDatePicker.minimumDate = startDate
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(self.datePickerHandler), for: UIControlEvents.valueChanged)
        startDatePick.inputView = startDatePicker
        startDatePick.text = "\(dateFormatter.string(from: startDate!))"
        
        updateEndDate(startDate: startDate!)
        endDatePicker.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(self.datePickerHandler), for: UIControlEvents.valueChanged)
        endDatePick.inputView = endDatePicker
    }

    func updateEndDate(startDate: Date){
        var components = DateComponents()
        components.day = 7
        let minEndDate = Calendar.current.date(byAdding: components, to: startDate)
        endDatePicker.minimumDate = minEndDate
        
        components.day = 30
        endDate = Calendar.current.date(byAdding: components, to: startDate)
        endDatePick.text = "\(dateFormatter.string(from: endDate!))"
    }
    override func viewWillDisappear(_ animated: Bool) {
        if photoIsUploading && uploadTask != nil{
            uploadTask!.cancel()
        }
        if self.challenge == nil && self.savedImgId != nil && self.savedImgId != ""{
            self.deletePhoto()
        }
    }
    deinit {
        if ref != nil {
            ref.removeAllObservers()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func datePickerHandler(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if sender == startDatePicker {
            startDate = startDatePicker.date
            startDatePick.text = "\(dateFormatter.string(from: startDate!))"
            updateEndDate(startDate: startDatePicker.date)
            startDatePick.resignFirstResponder()
        } else {
            endDate = endDatePicker.date
            endDatePick.text = "\(dateFormatter.string(from: endDate!))"
            endDatePick.resignFirstResponder()
        }
    }
    
    @IBAction func createChallenge(_ sender: UIButton) {
        let chalRef = ref.child(Constants.Challenge.table_name).childByAutoId()
        if userId != nil && userId != "" {
            chalRef.child(Constants.Challenge.created_by).setValue(userId)
        }
        if nameTextField.text != "" {
            chalRef.child(Constants.Challenge.challenge_name).setValue("\(nameTextField.text!)")
        }
        if savedImgId != nil && savedImgId != "" {
            chalRef.child(Constants.Challenge.chal_photo).setValue("\(savedImgId!)")
        }
        if groupPick.text != "" {
            chalRef.child(Constants.Challenge.for_group).setValue("\(groupPick.text!)")
        }
        if startDatePick.text != "" {
            chalRef.child(Constants.Challenge.start_date).setValue(self.startDate!.timeIntervalSince1970)
        }
        if endDatePick.text != "" {
            chalRef.child(Constants.Challenge.end_date).setValue(self.endDate!.timeIntervalSince1970)
        }
        if chalTotLongRunDist.text != "" {
            chalRef.child(Constants.Challenge.total_long_wo_dist).setValue(Double(chalTotLongRunDist.text!))
        }
        if chalTotLongRun.text != "" {
            chalRef.child(Constants.Challenge.total_long_wo_no).setValue(Int(chalTotLongRun.text!))
        }
        if chalTotWOPick.text != "" {
            chalRef.child(Constants.Challenge.total_wo_no).setValue(Int(chalTotWOPick.text!))
        }
        if chalToDistPick.text != "" {
            chalRef.child(Constants.Challenge.total_distant).setValue(Double(chalToDistPick.text!))
        }
        if weekTotWOPick.text != "" {
            chalRef.child(Constants.Challenge.week_wo_no).setValue(Int(weekTotWOPick.text!))
        }
        if weekTotDistPick.text != "" {
            chalRef.child(Constants.Challenge.week_distant).setValue(Double(weekTotDistPick.text!))
        }
        if weekLongRunPick.text != "" {
            chalRef.child(Constants.Challenge.week_long_wo_no).setValue(Int(weekLongRunPick.text!))
        }
        if weekLongRunDistPick.text != "" {
            chalRef.child(Constants.Challenge.week_long_wo_dist).setValue(Double(weekLongRunDistPick.text!))
        }
        if woMinDistPick.text != "" {
            chalRef.child(Constants.Challenge.min_wo_dist).setValue(Double(woMinDistPick.text!))
        }
        if woMinPacePick.text != "" {
            chalRef.child(Constants.Challenge.min_wo_pace).setValue(Double(woMinPacePick.text!))
        }
        chalRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? NSDictionary) != nil{
                self.challenge = Challenge(snapshot: snapshot)
                self.createBtn.isHidden = true
                self.deleteBtn.isHidden = false
            }
        })
    }
    func loadGroup(){
        self.ref.child(Constants.Group.TABLE_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren(){
                for challengeData in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let group = Group(snapshot: challengeData)
                    self.groups.append(group)
                }
            }
        }, withCancel: { (error) in
            print(error)
        })
    }

    @IBAction func selectImage(_ sender: UIButton) {
        imagePicker = WDImagePicker()
        imagePicker.cropSize = CGSize(width: 200, height: 200)
        imagePicker.delegate = self
        present(imagePicker.imagePickerController, animated: true, completion: nil)
    }
    @IBAction func deleteChallenge(_ sender: UIButton) {
        let challengePath = "\(Constants.Challenge.table_name)/\(self.challenge!.id)"
        
        let chalRecord = ref.child(challengePath)
        //        print(userRecord)
        chalRecord.removeValue { (error, refer) in
            if error != nil {
                print(error!)
            } else {
                self.deleteBtn.isHidden = true
                self.createBtn.isHidden = false
                self.clearInput()
            }
        }
    }
    func clearInput(){
        setupDatePicker()
        chalTotLongRunDist.text = ""
        chalTotLongRun.text = ""
        chalTotWOPick.text = ""
        chalToDistPick.text = ""
        weekTotWOPick.text = ""
        weekTotDistPick.text = ""
        weekLongRunPick.text = ""
        weekLongRunDistPick.text = ""
        woMinDistPick.text = ""
        woMinPacePick.text = ""
    }
    var savedImgId: String?
    func uploadPhoto(){
        savedImgId = ""
        if let data: Data = UIImagePNGRepresentation(chalImg!){
            uploadImgProgress.isHidden = false
            uploadImgProgress.setProgress(0.0, animated: true)
            let randomId = UUID().uuidString
            let chalImgRef = chalStorageRef.child(randomId)
            photoIsUploading = true
            createBtn.isEnabled = false
            
            uploadTask = chalImgRef.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.savedImgId = "\(metadata.downloadURL()!)"
                self.uploadImgProgress.isHidden = true
                self.photoIsUploading = false
                self.createBtn.isEnabled = true
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.uploadImgProgress.setProgress(Float(percentComplete.divided(by: 100.0)), animated: true)
            }
        }
    }
    func deletePhoto(){
        // Create a reference to the file to delete
        let currentImgRef = chalStorageRef.child(savedImgId!)
        
        // Delete the file
        currentImgRef.delete { error in
            if let error = error {
                print(error)
            } else {
                self.savedImgId = ""
            }
        }
    }
}
extension AddChallengeVC: UIPickerViewDelegate, UIPickerViewDataSource, WDImagePickerDelegate, UINavigationControllerDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groups.count + 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{
            selectedGroupId = fixedData[0]
            groupPick.text = fixedData[0]
        } else if row == 1{
            selectedGroupId = fixedData[1]
            groupPick.text = fixedData[1]
        } else {
            if groups.count > 0 {
                selectedGroupId = groups[row-2].key
                groupPick.text = groups[row-2].name
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return fixedData[0]
        } else if row == 1{
            return  fixedData[1]
        } else {
            return groups[row-2].name
        }
    }
    func closePicker() {
        groupPick.resignFirstResponder()
    }
    
    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage) {
        chalImg = resizeImage(image: pickedImage, targetSize: CGSize(width: 200, height: 200))
        uploadPhotoBtn.setImage(chalImg, for: .normal)
        uploadPhoto()
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
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
//
//extension AddChallengeVC: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
////    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
////        switch section {
////        case 0:
////            return "Challenge Target"
////        case 1:
////            return "Weekly Target"
////        default:
////            return "Workout Target"
////        }
////    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
////        switch section {
////        case 2:
////            return 2
////        default:
////            return 4
////        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TextSettingCell", for: indexPath) as! TextSettingCell
//        values[indexPath.row] = cell.settingTextField.text!
//        cell.selectionStyle = .none
//        switch indexPath.row {
//        case 0:
//            cell.settingLabel.text = "Total Workout"
//            cell.settingTextField.placeholder = "22"
//        case 1:
//            cell.settingLabel.text = "Total Distance"
//            cell.settingTextField.placeholder = "70.0"
//        case 2:
//            cell.settingLabel.text = "Total Long Run"
//            cell.settingTextField.placeholder = "4"
//        case 3:
//            cell.settingLabel.text = "Min. Long Run Distance"
//            cell.settingTextField.placeholder = "6.0"
//        case 4:
//            cell.settingLabel.text = "Weekly Workout"
//            cell.settingTextField.placeholder = "4"
//        case 5:
//            cell.settingLabel.text = "Weekly Distance"
//            cell.settingTextField.placeholder = "15.0"
//        case 6:
//            cell.settingLabel.text = "Weekly Long Run"
//            cell.settingTextField.placeholder = "1"
////            if ( "" != cell.currentVar ) {
////                cell.settingTextField.text = "\(cell.currentVar)"
////                chalWeekTotalLongRun = Int(cell.currentVar)!
////            }
//        case 7:
//            cell.settingLabel.text = "Weekly Long Run Dist."
//            cell.settingTextField.placeholder = "6.0"
////            if ( "" != cell.currentVar ) {
////                cell.settingTextField.text = "\(cell.currentVar)"
////                chalWeekMinLongRunDistance = Double(cell.currentVar)!
////            }
//        case 8:
//            cell.settingLabel.text = "Minimum Distance"
//            cell.settingTextField.placeholder = "3.0"
////            if ( "" != cell.currentVar ) {
////                cell.settingTextField.text = "\(cell.currentVar)"
////                chalTargetDistance = Double(cell.currentVar)!
////            }
//        default:
//            cell.settingLabel.text = "Minimum Pace"
//            cell.settingTextField.placeholder = "8.0"
////            if ( "" != cell.currentVar ) {
////                cell.settingTextField.text = "\(cell.currentVar)"
////                chalTargetPace = Double(cell.currentVar)!
////            }
//        }
//        return cell
//    }
//
//    
//}
