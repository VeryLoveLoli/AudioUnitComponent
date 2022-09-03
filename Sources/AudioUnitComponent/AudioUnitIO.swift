//
//  AudioUnitIO.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频IO
 */
open class AudioUnitIO: AudioUnit {
    
    /// 总线0（默认音频输入输出在总线0）
    public let element_0: UInt32 = 0
    /// 总线1
    public let element_1: UInt32 = 1
    
    /**
     开启麦克风
     */
    open func microphone() -> OSStatus {
        
        var status: OSStatus = noErr
        
        var flag: UInt32 = 1
        
        /// 音频输入 ---> 总线1
        status = AudioUnitSetProperty(instance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, element_1, &flag, UInt32(MemoryLayout.stride(ofValue: flag)))
        
        Print.debug("kAudioOutputUnitProperty_EnableIO kAudioUnitScope_Input \(status)")
        
        guard status == noErr else { return status }
        
        /// 音频流输出 ---> 总线1
        status = output(element_1, asbd: basic)
        
        return status
    }
    
    /**
     开启扬声器
     */
    open func speaker() -> OSStatus {
        
        var status: OSStatus = noErr
        
        var flag: UInt32 = 1
        
        /// 音频输出 ---> 总线0
        status = AudioUnitSetProperty(instance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, element_0, &flag, UInt32(MemoryLayout.stride(ofValue: flag)))
        
        Print.debug("kAudioOutputUnitProperty_EnableIO kAudioUnitScope_Output \(status)")
        
        /// 音频流输入 ---> 总线0
        status = input(element_0, asbd: basic)
        
        return status
    }
    
    /**
     开始
     */
    open func start() -> OSStatus {
        
        /// 初始化
        var status = AudioUnitInitialize(instance)
        
        Print.debug("AudioUnitInitialize \(status)")
        
        guard status == noErr else { return status }
        
        status = AudioOutputUnitStart(instance)
        
        Print.debug("AudioOutputUnitStart \(status)")
        
        return status
    }
    
    /**
     停止
     */
    @discardableResult open func stop() -> OSStatus {
        
        var status = AudioOutputUnitStop(instance)
        
        Print.debug("AudioOutputUnitStop \(status)")
        
        guard status == noErr else { return status }
        
        status = AudioUnitUninitialize(instance)
        
        Print.debug("AudioUnitUninitialize \(status)")
        
        return status
    }
}
