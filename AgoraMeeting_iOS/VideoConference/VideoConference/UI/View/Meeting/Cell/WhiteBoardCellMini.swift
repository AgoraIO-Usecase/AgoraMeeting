//
//  WhiteBoardCellMini.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/2.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import Whiteboard
import WhiteModule

class WhiteBoardCellMini: UICollectionViewCell {
    var boardView = WhiteManager.createWhiteBoardView()
    let videoMaskImageView = UIImageView()
    let upButton = UIButton()
    
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
        upButton.setImage(UIImage(named: "置顶默认状态"), for: .normal)
        upButton.setImage(UIImage(named:"置顶点击后状态"), for: .selected)
        videoMaskImageView.image = UIImage(named: "video-mask")
        videoMaskImageView.contentMode = .scaleToFill
        
        contentView.addSubview(boardView)
        contentView.addSubview(videoMaskImageView)
        contentView.addSubview(upButton)
        
        boardView.translatesAutoresizingMaskIntoConstraints = false
        videoMaskImageView.translatesAutoresizingMaskIntoConstraints = false
        upButton.translatesAutoresizingMaskIntoConstraints = false
        
        videoMaskImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        videoMaskImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        videoMaskImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        videoMaskImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        boardView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        boardView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        boardView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        boardView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        upButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        upButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        upButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
    }
   
}
