//
//  Util.swift
//  SpaceAids
//
//  Created by Kevin Chen on 3/10/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class Util {
    static func getVisibleScreen( sceneWidth: CGFloat, sceneHeight: CGFloat, viewWidth: CGFloat, viewHeight: CGFloat) -> CGRect {
        var sceneWidth = sceneWidth
        var sceneHeight = sceneHeight
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        let deviceAspectRatio = viewWidth/viewHeight
        let sceneAspectRatio = sceneWidth/sceneHeight
        
        if deviceAspectRatio < sceneAspectRatio {
            let newSceneWidth: CGFloat = (sceneWidth * viewHeight) / sceneHeight
            let sceneWidthDifference: CGFloat = (newSceneWidth - viewWidth)/2
            let diffPercentageWidth: CGFloat = sceneWidthDifference / (newSceneWidth)
            
            x = diffPercentageWidth * sceneWidth
            sceneWidth = sceneWidth - (diffPercentageWidth * 2 * sceneWidth)
        } else {
            let newSceneHeight: CGFloat = (sceneHeight * viewWidth) / sceneWidth
            let sceneHeightDifference: CGFloat = (newSceneHeight - viewHeight)/2
            let diffPercentageHeight: CGFloat = fabs(sceneHeightDifference / (newSceneHeight))
            
            y = diffPercentageHeight * sceneHeight
            sceneHeight = sceneHeight - (diffPercentageHeight * 2 * sceneHeight)
        }
        
        let visibleScreenOffset = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(sceneWidth), height: CGFloat(sceneHeight))
        return visibleScreenOffset
    }
    
    static func SDistanceBetweenPoints(first: CGPoint, second: CGPoint)->CGFloat{
        return CGFloat(hypotf(Float(second.x - first.x), Float(second.y - first.y)));
    }
}

enum BitMasksEnum {
    static let BLOCK_CONTACT_BM:UInt32 = 1
    static let HIT_CONTACT_BM:UInt32 = 2
    static let CRIT_CONTACT_BM:UInt32 = 4
    static let ALL_BLOCK_CATEGORY_BM:UInt32 = 0xFFFFFFFF
}
