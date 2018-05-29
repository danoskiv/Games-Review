//
//  NewCategoryController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/12/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class NewCategoryController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let labelImage: UILabel = {
        let label = UILabel()
        label.text = "Select a cover image for the game"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let imagePicker: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Warcraftiii-frozen-throne-boxcover")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ADD GAME", for: .normal)
        button.backgroundColor = UIColor(r: 0, g: 0, b: 70)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
       button.addTarget(self, action: #selector(handleAddGame), for: .touchUpInside)
        
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.placeholder = "Title of the game"
        tf.backgroundColor = UIColor.white
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5, height: tf.frame.height))
        tf.leftView = leftView
        tf.leftViewMode = .always
        tf.layer.cornerRadius = 3
        tf.layer.masksToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.layer.borderColor = UIColor.lightGray.cgColor
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5, height: tf.frame.height))
        tf.leftView = leftView
        tf.leftViewMode = .always
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 3
        tf.backgroundColor = UIColor.white
        tf.layer.masksToBounds = true
        tf.placeholder = "Short description"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let image = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelCategory))
        self.title = "Add a new game"
        
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        view.addSubview(labelImage)
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(addButton)
        setupLabelImageView()
        image.image = UIImage(named: "Warcraftiii-frozen-throne-boxcover")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.handleSelectProfileImage))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(image)
        setupImageView(image: image)
        setupTextFields()
        setupAddButton()
    }
    
    func setupTextFields() {
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 24).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        descriptionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        descriptionTextField.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
    func setupAddButton() {
        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 24).isActive = true
        addButton.widthAnchor.constraint(equalTo: descriptionTextField.widthAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupImageView(image: UIImageView) {
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.topAnchor.constraint(equalTo: labelImage.bottomAnchor, constant: 24).isActive = true
        image.widthAnchor.constraint(equalToConstant: 150).isActive = true
        image.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    func setupLabelImageView() {
        labelImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let height = (self.navigationController?.navigationBar.frame.size.height)! + 32.0
        labelImage.topAnchor.constraint(equalTo: view.topAnchor, constant: height).isActive = true
    }
    
    @objc func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            image.image = selectedImage
            image.heightAnchor.constraint(equalToConstant: 250).isActive = true
            image.widthAnchor.constraint(equalToConstant: 150).isActive = true
            image.contentMode = .scaleAspectFill
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAddGame() {
        guard let name = nameTextField.text, let desc = descriptionTextField.text else {
            return
        }
        let coverName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("game_covers").child("\(coverName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.image.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                storageRef.downloadURL(completion: { (url, er) in
                    if er != nil {
                        print(er!)
                        return
                    }
                    if let gameCover = url?.absoluteString {
                        let values = ["name": name, "desc": desc, "gameCover": gameCover, "timesRated": 0, "rating": 0] as [String : Any]
                        self.uploadANewGame(values: values)
                    }
                })
            })
        }
    }
    
    private func uploadANewGame(values: [String: Any])
    {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let newRef = ref.child("games").childByAutoId()
        newRef.updateChildValues(values)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancelCategory() {
        dismiss(animated: true, completion: nil)
    }
}
