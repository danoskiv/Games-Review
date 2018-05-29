//
//  MakeReviewController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/14/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class MakeReviewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var game: Game?
    
    let reviewText: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isSelectable = true
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        return tv
    }()
    
    let pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.backgroundColor = UIColor(r: 255, g: 255, b: 220)
        return pv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(2, inComponent: 0, animated: true)
        view.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        navigationItem.title = "Post a review"
        
        setupContainerView()
    }
    
    func setupContainerView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonPost = UIButton(type: .system)
        buttonPost.setTitle("POST", for: .normal)
        buttonPost.translatesAutoresizingMaskIntoConstraints = false
        buttonPost.backgroundColor = UIColor(r: 66, g: 197, b: 244)
        buttonPost.layer.cornerRadius = 5
        buttonPost.layer.masksToBounds = true
        buttonPost.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        buttonPost.setTitleColor(UIColor.white, for: .normal)
        buttonPost.addTarget(self, action: #selector(postReview), for: .touchUpInside)
        
        let label = UILabel()
        label.text = "Write your review"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let rateLabel = UILabel()
        rateLabel.text = "Rate the game"
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(pickerView)
        view.addSubview(rateLabel)
        view.addSubview(reviewText)
        view.addSubview(buttonPost)
        
        rateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let height = (self.navigationController?.navigationBar.frame.size.height)! + 24.0
        rateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: height).isActive = true
        
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 8).isActive = true
        pickerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 8).isActive = true
        
        reviewText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reviewText.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        reviewText.heightAnchor.constraint(equalToConstant: 60).isActive = true
        reviewText.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        
        buttonPost.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonPost.widthAnchor.constraint(equalToConstant: 80).isActive = true
        buttonPost.topAnchor.constraint(equalTo: reviewText.bottomAnchor, constant: 8).isActive = true
        
    }
    var reviewsController: ReviewsController?
    @objc func postReview() {
        var ref: DatabaseReference!
        ref = Database.database().reference().child("reviews").childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let rate = pickerView.selectedRow(inComponent: 0)
        let values = ["rate": rate, "reviewText": reviewText.text, "userId": fromId!, "gameId": game!.gid!, "timestamp": timestamp] as [String : Any]
        ref.updateChildValues(values)
        var gameRef: DatabaseReference!
        gameRef = Database.database().reference().child("games").child(game!.gid!)
        gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let newGame = Game()
                newGame.gid = self.game?.gid
                newGame.name = dictionary["name"] as? String
                newGame.desc = dictionary["desc"] as? String
                newGame.coverPhoto = dictionary["gameCover"] as? String
                let ratingOld = dictionary["rating"] as? Int
                let timesOld = dictionary["timesRated"] as? Int
                newGame.rating = ratingOld! + rate + 1
                newGame.timesRated = timesOld! + 1
                let newValues = ["name": newGame.name!, "desc": newGame.desc!, "gameCover": newGame.coverPhoto!, "rating": newGame.rating!, "timesRated": newGame.timesRated!] as [String:Any]
                self.updateGameValues(values: newValues, gameId: newGame.gid!)
            }
        }, withCancel: nil)
    }
    
    func updateGameValues(values: [String:Any], gameId: String) {
        let ref = Database.database().reference().child("games").child(gameId)
        ref.updateChildValues(values)
        
        let navController = UINavigationController(rootViewController: ReviewsController())
        present(navController, animated: true) {
            DispatchQueue.main.async {
                self.reviewsController?.tableView.reloadData()
            }
        }
    }
    
    let choice = ["It's awful", "Nothing special", "Meh", "Maybe I'll play it if I don't have Internet", "IT'S AWESOME"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choice.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choice[row]
    }
    
}
