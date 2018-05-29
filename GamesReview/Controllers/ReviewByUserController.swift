//
//  ReviewByUserController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/25/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class ReviewByUserController: UITableViewController {

    var game: Game?
    var reviews = [Review]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SingleReviewCell.self, forCellReuseIdentifier: cellId)
        self.title = "Reviews by users"
        
        observeReviews()
    }
    
    func observeReviews() {
        let ref = Database.database().reference().child("reviews")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let gameId = dictionary["gameId"] as? String
                if gameId == self.game?.gid {
                    let review = Review()
                    review.gameId = dictionary["gameId"] as? String
                    review.rate = dictionary["rate"] as? Int
                    review.reviewText = dictionary["reviewText"] as? String
                    review.timestamp = dictionary["timestamp"] as? Int
                    review.userId = dictionary["userId"] as? String
                    self.reviews.append(review)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SingleReviewCell
        let review = reviews[indexPath.row]
        cell.review = review
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = reviews[indexPath.row]
        let detailsController = ReviewDetailsController()
        detailsController.review = review
        navigationController?.pushViewController(detailsController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

class SingleReviewCell: UITableViewCell {
    var review: Review? {
        didSet {
            let rate = (review?.rate)! + 1
            
            let userReference = Database.database().reference().child("users").child(review!.userId!)
            let gameReference = Database.database().reference().child("games").child(review!.gameId!)
            
            userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any] {
                    gameReference.observeSingleEvent(of: .value, with: { (gameSnapshot) in
                        if let gameDictionary = gameSnapshot.value as? [String:Any] {
                            let gameName = gameDictionary["name"] as? String
                            let userName = dictionary["username"] as? String
                            self.label.text = userName! + " rated " + gameName! + " with " + "\"" + String(rate) + "\""
                            self.numberLabel.text = "Check what " + userName! + " has said"
                            if let url = gameDictionary["gameCover"] as? String {
                                self.imageView?.loadImageWithCacheFromUrlString(urlString: url)
                            }
                        }
                    }, withCancel: nil)
                }
            }, withCancel: nil)

            self.backgroundColor = UIColor.lightGray
            let screenSize = UIScreen.main.bounds
            let separatorHeight = CGFloat(7.0)
            let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-separatorHeight, width: screenSize.width, height: separatorHeight))
            additionalSeparator.backgroundColor = UIColor.white
            self.addSubview(additionalSeparator)
        }
    }
    
    override func prepareForReuse() {
        textLabel?.text = ""
    }
    
    let gameCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let label: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = UIColor.white
        lab.lineBreakMode = .byWordWrapping
        lab.font = UIFont.boldSystemFont(ofSize: 16)
        return lab
    }()
    
    let numberLabel: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 12)
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = UIColor.white
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(gameCoverView)
        addSubview(label)
        addSubview(numberLabel)
        
        //x,y,width,height constraints
        gameCoverView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        gameCoverView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        gameCoverView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        gameCoverView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //label constraints
        label.leftAnchor.constraint(equalTo: gameCoverView.rightAnchor, constant: 24).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -16).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/2).isActive = true
        
        //number label constraints
        numberLabel.leftAnchor.constraint(equalTo: gameCoverView.rightAnchor, constant: 24).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 16).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        numberLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/2).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
