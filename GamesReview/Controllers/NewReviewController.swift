//
//  NewReviewController.swift
//  GamesReview
//
//  Created by Vladimir Danoski on 5/12/18.
//  Copyright © 2018 Vladimir Danoski. All rights reserved.
//

import UIKit
import Firebase

class NewReviewController: UITableViewController {

    let cellId = "cellId"
    
    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelReview))
        self.title = "Select a game"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchGame()
        
    }
    
    func fetchGame() {
        Database.database().reference().child("games").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let game = Game()
                game.name = dictionary["name"] as? String
                game.desc = dictionary["desc"] as? String
                game.coverPhoto = dictionary["gameCover"] as? String
                game.gid = snapshot.key
                self.games.append(game)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancelReview() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let game = games[indexPath.row]
        let gameOriginal = Game()
        gameOriginal.name = game.name
        gameOriginal.desc = game.desc
        gameOriginal.coverPhoto = game.coverPhoto
        cell.textLabel?.text = game.name
        cell.detailTextLabel?.text = game.desc
        if let gameCoverUrl = game.coverPhoto {
            cell.gameCoverView.loadImageWithCacheFromUrlString(urlString: gameCoverUrl)
        }
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        let screenSize = UIScreen.main.bounds
        let separatorHeight = CGFloat(5.0)
        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: cell.frame.size.height-separatorHeight, width: screenSize.width, height: separatorHeight))
        additionalSeparator.backgroundColor = UIColor.lightGray
        cell.addSubview(additionalSeparator)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    var reviewController: ReviewsController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let game = self.games[indexPath.row]
            self.reviewController?.showMakeReview(game: game)
        }
    }
}

class UserCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let gameCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 14
//        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(gameCoverView)
        //x,y,width,height constraints
        gameCoverView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        gameCoverView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        gameCoverView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        gameCoverView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
