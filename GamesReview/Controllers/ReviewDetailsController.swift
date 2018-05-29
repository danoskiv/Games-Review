//
//  ReviewDetailsController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/17/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class ReviewDetailsController: UIViewController {

    var review: Review?
    
    let rateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let rLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rateRedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 20)
        return label
    }()
    
    let helperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Review details"
        view.backgroundColor = UIColor.white
        
        fetchUserAndGame()
        
        view.addSubview(rateLabel)
        view.addSubview(helperLabel)
        view.addSubview(rLabel)
        view.addSubview(reviewLabel)
        view.addSubview(imageView)
        view.addSubview(rateRedLabel)
        
        setupImageView()
        setupRateLabel()
        setupRLabel()
        setupHelperLabel()
        setupReviewLabel()
        setupRedRateLabel()
    }
    var string = ""
    func fetchUserAndGame() {
        var rate = ""
        if let rating = review?.rate {
            switch rating {
            case 0:
                rate = "It's awful"
                break
            case 1:
                rate = "Nothing special"
                break
            case 2:
                rate = "Meh"
                break
            case 3:
                rate = "Maybe I'll play it if I don't have Internet"
                break
            case 4:
                rate = "IT'S AWESOME"
                break
            default:
                rate = "none"
                break
            }
        }
        guard let userId = review!.userId, let gameId = review!.gameId else {
            return
        }
        
        let refUser = Database.database().reference().child("users").child(userId)
        let gameRef = Database.database().reference().child("games").child(gameId)

        refUser.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let username = dictionary["username"] as? String
                gameRef.observeSingleEvent(of: .value, with: { (gameSnapshot) in
                    if let gameDictionary = gameSnapshot.value as? [String: AnyObject] {
                        let gameName = gameDictionary["name"] as? String
                        if let userUrl = dictionary["profileImageUrl"] as? String {
                            self.imageView.loadImageWithCacheFromUrlString(urlString: userUrl)
                        }
                        self.rateLabel.text = username! + " rated " + gameName!
                        self.rLabel.text = "Rate"
                        self.rateRedLabel.text = "\"" + rate + "\""
                        self.helperLabel.text = username! + "'s review: "
                        self.reviewLabel.text = "\"" + (self.review?.reviewText)! + "\""
                    }
                }, withCancel: nil)
            }
        }, withCancel: nil)
    }
    
    func setupRedRateLabel() {
        rateRedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rateRedLabel.topAnchor.constraint(equalTo: rLabel.bottomAnchor, constant: 12).isActive = true
        rateRedLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
    }
    
    func setupImageView() {
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let height = (self.navigationController?.navigationBar.frame.size.height)! + 24.0
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: height).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupRateLabel() {
        rateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
    }
    
    func setupRLabel() {
        rLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 32).isActive = true
    }
    
    func setupHelperLabel() {
        helperLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helperLabel.topAnchor.constraint(equalTo: rateRedLabel.bottomAnchor, constant: 24).isActive = true
    }
    
    func setupReviewLabel() {
        reviewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reviewLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        reviewLabel.topAnchor.constraint(equalTo: helperLabel.bottomAnchor, constant: 16).isActive = true
    }
    
}
