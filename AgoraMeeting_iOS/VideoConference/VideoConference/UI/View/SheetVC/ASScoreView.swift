//
//  ASScoreView.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import UIKit



class ASScoreView: UIView {

    let titleLabel = UILabel()
    var starView1: ASScoreStarView!
    var starView2: ASScoreStarView!
    var starView3: ASScoreStarView!
    let commentLabel = UILabel()
    let placeholderLabel = UILabel()
    let commentTextView = UITextView()
    let sureButton = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        starView1 = Bundle.main.loadNibNamed("ASScoreStarView", owner: nil, options: nil)?.first as? ASScoreStarView
        starView2 = Bundle.main.loadNibNamed("ASScoreStarView", owner: nil, options: nil)?.first as? ASScoreStarView
        starView3 = Bundle.main.loadNibNamed("ASScoreStarView", owner: nil, options: nil)?.first as? ASScoreStarView
        
        starView1.titleLabel.text = NSLocalizedString("score_t1", comment: "")
        starView2.titleLabel.text = NSLocalizedString("score_t2", comment: "")
        starView3.titleLabel.text = NSLocalizedString("score_t3", comment: "")
        
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.text = NSLocalizedString("score_t4", comment: "")
        titleLabel.textAlignment = .center
        
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        commentLabel.textColor = UIColor(hex: 0x2E3848)
        commentLabel.text = NSLocalizedString("score_t5", comment: "")
        
        commentTextView.layer.masksToBounds = true
        commentTextView.layer.cornerRadius = 2
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor(hex: 0xE9EFF4).cgColor
        commentTextView.returnKeyType = .done
        
        sureButton.setTitle(NSLocalizedString("score_t6", comment: ""), for: .normal)
        sureButton.setTitleColor(UIColor(hex: 0x4DA1FF), for: .normal)
        sureButton.showsTouchWhenHighlighted = true
        
        placeholderLabel.text = NSLocalizedString("score_t7", comment: "")
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = UIColor(hex: 0x989898)
        placeholderLabel.sizeToFit()
        placeholderLabel.font = UIFont.systemFont(ofSize: 12)
        commentTextView.addSubview(placeholderLabel)
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hex: 0xE5E5E5)
        
        addSubview(titleLabel)
        addSubview(starView1)
        addSubview(starView2)
        addSubview(starView3)
        addSubview(commentLabel)
        addSubview(commentTextView)
        addSubview(sureButton)
        addSubview(lineView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        starView1.translatesAutoresizingMaskIntoConstraints = false
        starView2.translatesAutoresizingMaskIntoConstraints = false
        starView3.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        sureButton.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                                     titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                                     titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([starView1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     starView1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     starView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                                     starView1.heightAnchor.constraint(equalToConstant: 66)])
        
        NSLayoutConstraint.activate([starView2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     starView2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     starView2.topAnchor.constraint(equalTo: starView1.bottomAnchor, constant: 5),
                                     starView2.heightAnchor.constraint(equalToConstant: 66)])
        
        NSLayoutConstraint.activate([starView3.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     starView3.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     starView3.topAnchor.constraint(equalTo: starView2.bottomAnchor, constant: 5),
                                     starView3.heightAnchor.constraint(equalToConstant: 66)])
        
        NSLayoutConstraint.activate([commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     commentLabel.topAnchor.constraint(equalTo: starView3.bottomAnchor, constant: 5)])
        
        NSLayoutConstraint.activate([commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     commentTextView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
                                     commentTextView.heightAnchor.constraint(equalToConstant: 60)])
        
        NSLayoutConstraint.activate([lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                                     lineView.heightAnchor.constraint(equalToConstant: 0.5)])
        
        
        NSLayoutConstraint.activate([sureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     sureButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     sureButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                                     sureButton.heightAnchor.constraint(equalToConstant: 49)])
        
        NSLayoutConstraint.activate([placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 5),
                                     placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 8)])
        
        commentTextView.delegate = self
        
    }
    
}

extension ASScoreView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            commentTextView.endEditing(true)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.count != 0
    }
}
