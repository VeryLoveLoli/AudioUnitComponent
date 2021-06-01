//
//  AudioStreamBasicDescription.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox

extension AudioStreamBasicDescription {
    
    /**
     PCM音频流参数
     
     - parameter    sampleRate:     采样率
     - parameter    bits:           采样位数
     - parameter    channel:        声道
     - parameter    packetFrames:   包帧数
     */
    public static func pcm(_ sampleRate: Float64 = 44100.00, bits: UInt32 = 32, channel: UInt32 = 2, packetFrames: UInt32 = 1) -> AudioStreamBasicDescription {
        
        var description = AudioStreamBasicDescription.init()
        
        /// 类型
        description.mFormatID = kAudioFormatLinearPCM
        /// flags
        description.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        /// 采样率
        description.mSampleRate = sampleRate
        /// 采样位数
        description.mBitsPerChannel = bits
        /// 声道
        description.mChannelsPerFrame = channel
        /// 每个包的帧数
        description.mFramesPerPacket = packetFrames
        /// 每个帧的字节数
        description.mBytesPerFrame = description.mBitsPerChannel / 8 * description.mChannelsPerFrame
        /// 每个包的字节数
        description.mBytesPerPacket = description.mBytesPerFrame * description.mFramesPerPacket
        
        return description
    }
}
