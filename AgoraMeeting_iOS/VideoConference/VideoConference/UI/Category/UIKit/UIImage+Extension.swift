//
//  UIImage+Extension.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/19.
//

import Foundation

extension UIImage {
    
    static func createGradientImage(startAt: CGPoint, startColor: UIColor, endAt:CGPoint, endColor: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let colors = [startColor.cgColor, endColor.cgColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) else { return nil }
        context.drawLinearGradient(gradient, start: startAt, end: endAt, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func coloredImage(color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func scale(to size: CGSize) -> UIImage {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        if let img = UIGraphicsGetImageFromCurrentImageContext() {
            return img
        }
        return self
    }
    
    
    
    func fit(to fitSize: CGSize) -> UIImage {
        var targetSize = self.size;
        
        if(self.size.width > fitSize.width && self.size.height > fitSize.height) {  // 当前图片的宽高都大与指定的宽高
            if (self.size.width > self.size.height) {   // 按宽为最大压缩
                targetSize.height = fitSize.width * (self.size.height / self.size.width);
                targetSize.width = fitSize.width;
            } else {    // 按高为最大压缩
                targetSize.width =  fitSize.height * (self.size.width / self.size.height);
                targetSize.height = fitSize.height;
            }
        } else if (self.size.width > fitSize.width) {   // 只有宽大
            targetSize.height = fitSize.width * (self.size.height / self.size.width);
            targetSize.width = fitSize.width;
        } else if (self.size.height > fitSize.height) { // 只有高大
            targetSize.width =  fitSize.height * (self.size.width / self.size.height);
            targetSize.height = fitSize.height;
        }
        return self.scale(to: targetSize)
    }
}
