//
//  NewsFeedCell.swift
//  NYTimesNow
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit

public class NewsFeedCell: UITableViewCell {
    
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var coverImageView: UIImageView!
    @IBOutlet private(set) public var dateLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "NewsFeedCell", bundle: Bundle(for: Self.self))
    }
}
