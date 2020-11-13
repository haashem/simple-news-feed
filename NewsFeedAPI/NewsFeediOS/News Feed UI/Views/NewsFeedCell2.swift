//
//  NewsFeedCell.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit

public class NewsFeedCell: UITableViewCell {

    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let dateLabel = UILabel()
    public let coverImageView = UIImageView()
    private let imageContainerView = UIView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(coverImageView)
        
        imageContainerView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFit
        imageContainerView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.85, alpha: 1)
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: 216).isActive = true
       
        titleLabel.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
}
