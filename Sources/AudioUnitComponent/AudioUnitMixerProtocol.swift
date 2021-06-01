//
//  AudioUnitMixerProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/5/31.
//

import Foundation
import AudioToolbox

/**
 音频混音器协议
 */
public protocol AudioUnitMixerProtocol {
    
    /**
     音频混音器输入回调
     
     - parameter    mixer:                      混音器
     - parameter    inBusNumber:                输入总线
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ mixer: AudioUnitMixer, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
    
    /**
     音频混音器输出回调
     
     - parameter    mixer:                      混音器
     - parameter    outBusNumber:               输出总线
     - parameter    inNumberFrames:             帧数
     - parameter    ioData:                     缓冲列表
     */
    func audioUnit(_ mixer: AudioUnitMixer, outBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}
