//
//  Date+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/24.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

extension Date {
    /// time string with formatter: yyyy/MM/dd HH:mm
    var timeString1: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
    
    /// HH:mm
    var timeString2: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// HH:mm a
    var timeString3: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: self)
    }
}
