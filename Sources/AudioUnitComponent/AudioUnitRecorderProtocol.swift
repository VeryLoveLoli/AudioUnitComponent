//
//  AudioUnitRecorderProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox

/**
 音频录制器协议
 */
public protocol AudioUnitRecorderProtocol {
    
    /**
     音频录制器回调
     
     - parameter    recorder:                   录制器
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ recorder: AudioUnitRecorder, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>)
}
