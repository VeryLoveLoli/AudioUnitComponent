//
//  AudioUnitPlayerProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox

/**
 音频播放器协议
 */
public protocol AudioUnitPlayerProtocol {
    
    /**
     音频播放器输入回调
     
     - parameter    player:                     播放器
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ player: AudioUnitPlayer, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
    
    /**
     音频播放器输出回调
     
     - parameter    player:                     混音器
     - parameter    outNumberFrames:            帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ player: AudioUnitPlayer, outNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}
