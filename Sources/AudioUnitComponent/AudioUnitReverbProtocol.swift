//
//  AudioUnitReverbProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/6/1.
//

import Foundation
import AudioToolbox

/**
 音频音响协议
 */
public protocol AudioUnitReverbProtocol {
    
    /**
     音频音响输入回调
     
     - parameter    reverb:                     音响
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ reverb: AudioUnitReverb, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}
