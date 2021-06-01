//
//  AudioUnitTimePitchProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/6/1.
//

import Foundation
import AudioToolbox

/**
 音频音调协议
 */
public protocol AudioUnitTimePitchProtocol {
    
    /**
     音频音调输入回调
     
     - parameter    timePitch:                  音调
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ timePitch: AudioUnitTimePitch, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}
