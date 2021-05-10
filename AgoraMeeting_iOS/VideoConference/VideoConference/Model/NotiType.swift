//
//  NotiType.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/16.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
enum NotiType: Int, CustomStringConvertible {
    case never = 0
    case n10 = 1
    case n20 = 2
    case n30 = 3
    case n40 = 4
    case n50 = 5
    case n60 = 6
    case n70 = 7
    case n80 = 8
    case n90 = 9
    case n100 = 10
    case always = 11
    
    var description: String {
        switch self {
        case .never:
            return NSLocalizedString("noti_t2", comment: "")
        case .n10:
            return "10" + NSLocalizedString("noti_t3", comment: "")
        case .n20:
            return "20" + NSLocalizedString("noti_t3", comment: "")
        case .n30:
            return "30" + NSLocalizedString("noti_t3", comment: "")
        case .n40:
            return "40" + NSLocalizedString("noti_t3", comment: "")
        case .n50:
            return "50" + NSLocalizedString("noti_t3", comment: "")
        case .n60:
            return "60" + NSLocalizedString("noti_t3", comment: "")
        case .n70:
            return "70" + NSLocalizedString("noti_t3", comment: "")
        case .n80:
            return "80" + NSLocalizedString("noti_t3", comment: "")
        case .n90:
            return "90" + NSLocalizedString("noti_t3", comment: "")
        case .n100:
            return "100" + NSLocalizedString("noti_t3", comment: "")
        case .always:
            return NSLocalizedString("noti_t4", comment: "")
        }
    }
    
}
