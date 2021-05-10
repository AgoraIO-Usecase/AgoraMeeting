//
//  ASSystemAlertPrensentAnimation.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/20.
//

import Foundation
import Presentr

public class ASSystemAlertPrensentAnimation: PresentrAnimation {
    
    public override init(options: AnimationOptions = .normal(duration: 0.25)) {
        super.init(options: options)
    }

    override public func beforeAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 0.0 : 1.0
        transitionContext.animatingView?.layer.transform = transitionContext.isPresenting ? CATransform3DMakeScale(1.2, 1.2, 1.0) : CATransform3DMakeScale(1.0, 1.0, 1.0)
    }

    override public func performAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 1.0 : 0.0
        transitionContext.animatingView?.layer.transform = transitionContext.isPresenting ? CATransform3DMakeScale(1.0, 1.0, 1.0) : CATransform3DMakeScale(1.2, 1.2, 1.0)
    }

    override public func afterAnimation(using transitionContext: PresentrTransitionContext) {
        transitionContext.animatingView?.alpha = 1.0
    }

}

