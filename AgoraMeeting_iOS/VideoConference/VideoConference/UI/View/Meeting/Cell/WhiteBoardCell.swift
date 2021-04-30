//
//  WhiteBoardCell.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/2.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import Whiteboard
import WhiteModule

class WhiteBoardCell: UICollectionViewCell {
    var boardView = WhiteManager.createWhiteBoardView()
    let videoMaskImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        boardView.isUserInteractionEnabled = false
        videoMaskImageView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        
        contentView.addSubview(boardView)
        contentView.addSubview(videoMaskImageView)
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        videoMaskImageView.translatesAutoresizingMaskIntoConstraints = false
        
        videoMaskImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        videoMaskImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        videoMaskImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        videoMaskImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        boardView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        boardView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        boardView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        boardView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
   
}
