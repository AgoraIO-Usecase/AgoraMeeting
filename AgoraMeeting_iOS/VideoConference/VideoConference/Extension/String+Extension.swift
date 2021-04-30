//
//  String+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/13.
//  Copyright © 2021 agora. All rights reserved.
//


import CommonCrypto
extension String {
    
    func md5() -> String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }.lowercased()
    }
    
    /// return tips when `UserName` was invalied
    var inValidUserNameText: String? {
        if count <= 0 {
            return NSLocalizedString("UserNameVerifyEmptyText", comment: "")
        }
        if count < 3 {
            return NSLocalizedString("UserNameMinVerifyText", comment: "")
        }
        if count > 20 {
            return NSLocalizedString("UserNameMaxVerifyText", comment: "")
        }
        return nil
    }
    
    /// return tips when `Psd` was invalied
    var inValidPsdText: String? {
        if count > 20 {
            return NSLocalizedString("PsdMaxVerifyText", comment: "")
        }
        return nil
    }
    
    /// return tips when `RoomName` was invalied
    var inValidRoomName: String? {
        if count <= 0 {
            return NSLocalizedString("UserNameVerifyEmptyText", comment: "")
        }
        if count <= 3 {
            return NSLocalizedString("RoomNameMinVerifyText", comment: "")
        }
        if count > 50 {
            return NSLocalizedString("RoomNameMaxVerifyText", comment: "")
        }
        return nil
    }
    
    /// userId to headImageName
    static func headImageName(userName: String) -> String {
        let index = userName.index(userName.endIndex, offsetBy: -2)
        let temp = userName.suffix(from: index)
        var result:UInt32 = 0
        Scanner(string: String(temp)).scanHexInt32(&result)
        let i = (result % 36)
        return "avatar_" + "\(i)"
    }
    
}

extension String {
    func agoraKitSize(font: UIFont,
              width: CGFloat = CGFloat(MAXFLOAT),
              height: CGFloat = CGFloat(MAXFLOAT)) -> CGSize {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,
                                               .usesFontLeading]
        let text = self as NSString
        let boundingRect = text.boundingRect(with: CGSize(width: width,
                                                          height: height),
                                             options: options,
                                             attributes: [NSAttributedString.Key.font:font],
                                             context: nil)
        return CGSize(width: boundingRect.size.width + 1,
                      height: boundingRect.size.height + 1)
    }
}

extension String {
 
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case
            0x00A0...0x00AF,
            0x2030...0x204F,
            0x2120...0x213F,
            0x2190...0x21AF,
            0x2310...0x329F,
            0x1F000...0x1F9CF:
                return true
            default:
                continue
            }
        }
        return false
    }
 
}
