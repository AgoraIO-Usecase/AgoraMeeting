//
//  MeetingVM+Data+Calculate.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/23.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation


extension MeetingVM {
    
    private func shouldUpdateInfo(update: UpdateInfo) -> UpdateInfo? {
        guard let old = lastUpdate else {
            lastUpdate = update
            return update
        }
        
        guard old != update else {
            return nil
        }
        
        if old.mode == update.mode {
            /// update
            /// delete
            /// add
        }
        return lastUpdate
    }
    
    private func calculateUpdatesForVideoMode(olds: [VideoCell.Info], news: [VideoCell.Info]) -> UpdateItem<VideoCell.Info> {
        
        if olds.count == 0, news.count == 0 { return UpdateItem<VideoCell.Info>(indexPaths: [], afterList: []) }
        if olds.count == 0, news.count != 0 {
            return UpdateItem<VideoCell.Info>(indexPaths: [], afterList: [])
        }
        
        
        
                
        return UpdateItem<VideoCell.Info>(indexPaths: [], afterList: [])
    }
    
//    private func calculateAdds(old: UpdateInfo, new: UpdateInfo) -> [String] {
//        return []
//    }
//
//    private func calculateDeteles(old: UpdateInfo, new: UpdateInfo) -> [String] {
//        return []
//    }
    
    
    struct UpdateItem<Element: Equatable> {
        let indexPaths: [IndexPath]
        let afterList: [Element]
    }
}
