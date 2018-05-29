//
//  ViewController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/12/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class ReviewsController: UITableViewController {
    
    var reviews = [Review]()
    var users = [User]()
    var games = [Game]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeReviews()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleLogout))
        let newReview = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewReview))
        let addCategory = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewCategory))
        navigationItem.rightBarButtonItem = addCategory
        navigationItem.rightBarButtonItems?.append(newReview)
        tableView.register(ReviewCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        checkIfUserIsLoggedIn()
    }
    
    func observeReviews() {
        let ref = Database.database().reference().child("games")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let game = Game()
                game.gid = snapshot.key
                game.name = dictionary["name"] as? String
                game.desc = dictionary["desc"] as? String
                game.rating = dictionary["rating"] as? Int
                game.timesRated = dictionary["timesRated"] as? Int
                game.coverPhoto = dictionary["gameCover"] as? String
                self.games.append(game)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleNewCategory() {
        let navController = UINavigationController(rootViewController: NewCategoryController())
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleNewReview() {
        let newReviewController = NewReviewController()
        newReviewController.reviewController = self
        let navController = UINavigationController(rootViewController: newReviewController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            authenticateUserAndChangeNavBar()
        }
    }
    
    func authenticateUserAndChangeNavBar()
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.username = dictionary["username"] as? String
                user.email = dictionary["email"] as? String
                user.profilePicture = dictionary["profileImageUrl"] as? String
                self.setupnavBarTitle(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupnavBarTitle(user: User)
    {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        if let profileImageUrl = user.profilePicture {
            profileImageView.loadImageWithCacheFromUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        //constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        titleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    func showMakeReview(game: Game) {
        let makeReviewController = MakeReviewController()
        makeReviewController.game = game
        navigationController?.pushViewController(makeReviewController, animated: true)
        
    }

    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.reviewsController = self
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReviewCell
        let game = games[indexPath.row]
        cell.game = game
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        let allReviewsForGame = ReviewByUserController()
        allReviewsForGame.game = game
        navigationController?.pushViewController(allReviewsForGame, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    
}

class ReviewCell: UITableViewCell {
    var game: Game? {
        didSet {
            let timesRated = game!.timesRated!
            let rating = game!.rating!
            let result = Float(rating)/Float(timesRated)
            self.label.text = "RATING "
            self.numberLabel.text = String(format: "%.1f", result)
            if let url = game?.coverPhoto {
                self.gameCoverView.loadImageWithCacheFromUrlString(urlString: url)
            }
            
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 12 + 12 + 12 + (2*self.frame.width)/3, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
    }
    
    let gameCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        lab.font = UIFont.boldSystemFont(ofSize: 20)
        return lab
    }()
    
    let numberLabel: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 20)
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = UIColor.white
        lab.lineBreakMode = .byWordWrapping
        lab.layer.cornerRadius = 23
        lab.layer.masksToBounds = true
        lab.backgroundColor = UIColor.red
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
        gameCoverView.widthAnchor.constraint(equalToConstant: (2 * self.frame.width)/3).isActive = true
        gameCoverView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8).isActive = true
        
        //label constraints
        label.leftAnchor.constraint(equalTo: gameCoverView.rightAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -24).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        //number label constraints
        var widthForLabel = self.frame.width - ((2 * self.frame.width)/3)
        widthForLabel = widthForLabel/2
//        numberLabel.leftAnchor.constraint(equalTo: gameCoverView.rightAnchor, constant: 50).isActive = true
        numberLabel.leftAnchor.constraint(equalTo: gameCoverView.rightAnchor, constant: widthForLabel).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 24).isActive = true
//        numberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -52).isActive = true
        numberLabel.widthAnchor.constraint(equalToConstant: 46).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 46).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

