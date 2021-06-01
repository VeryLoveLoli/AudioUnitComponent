//
//  AudioUnit.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频单元
 */
open class AudioUnit {
    
    /**
     对象转指针
     */
    public static func bridge<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
        
        return Unmanaged.passUnretained(obj).toOpaque()
    }
    
    /**
     指针转对象
     */
    public static func bridge<T: AnyObject>(raw: UnsafeRawPointer) -> T {
        
        return Unmanaged<T>.fromOpaque(raw).takeUnretainedValue()
    }
    
    /// 音频参数
    open internal(set) var basic: AudioStreamBasicDescription
    /// 设备参数
    open internal(set) var description: AudioComponentDescription
    /// 音频设备
    open internal(set) var component: AudioComponent
    /// 设备实例
    open internal(set) var instance: AudioComponentInstance
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数
     - parameter    componentDescription:       音频设备参数
     */
    public init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription) {
        
        basic = streamBasicDescription
        description = componentDescription
        
        /// 获取音频设备
        guard let audioComponent = AudioComponentFindNext(nil, &description) else { Print.error("AudioComponentFindNext error"); return nil }
        
        component = audioComponent
        
        var status: OSStatus = noErr
        
        var componentInstance: AudioComponentInstance?
        
        /// 获取音频设备实例
        status = AudioComponentInstanceNew(component, &componentInstance)
        
        Print.debug("AudioComponentInstanceNew \(status)")
        
        guard status == noErr else { return nil }
        
        instance = componentInstance!
    }
    
    /**
     设置全局
     
     - parameter    bus:        总线
     - parameter    enable:     是否启用
     */
    open func global(_ bus: UInt32, enable: Bool) -> OSStatus {
        
        var flag: UInt32 = enable ? 1 : 0
        
        let status = AudioUnitSetProperty(instance, kMultiChannelMixerParam_Enable, kAudioUnitScope_Global, bus, &flag, UInt32(MemoryLayout.stride(ofValue: flag)))
        
        Print.debug("kMultiChannelMixerParam_Enable kAudioUnitScope_Global AudioUnitElement_\(bus) \(status)")
        
        return status
    }
    
    /**
     设置输出
     
     - parameter    bus:    总线
     - parameter    asbd:   音频参数
     */
    open func output(_ bus: UInt32, asbd: AudioStreamBasicDescription) -> OSStatus {
        
        var asbd = asbd
        
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, UInt32(MemoryLayout.stride(ofValue: asbd)))
        
        Print.debug("kAudioUnitProperty_StreamFormat kAudioUnitScope_Output \(status)")
        
        return status
    }
    
    /**
     设置输入
     
     - parameter    bus:    总线
     - parameter    asbd:   音频参数
     */
    open func input(_ bus: UInt32, asbd: AudioStreamBasicDescription) -> OSStatus {
        
        var asbd = asbd
        
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, AudioUnitElement(bus), &asbd, UInt32(MemoryLayout.stride(ofValue: asbd)))
        
        Print.debug("kAudioUnitProperty_StreamFormat kAudioUnitScope_Input AudioUnitElement_\(bus) \(status)")
        
        return status
    }
    
    /**
     设置输入
     
     - parameter    bus:        总线
     - parameter    volume:     音量 0->1, 1.
     */
    open func input(_ bus: UInt32, volume: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        let status =  AudioUnitSetParameter(instance, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, bus, volume, inBufferOffsetInFrames)
        
        return status
    }
    
    /**
     设置输出
     
     - parameter    bus:        总线
     - parameter    volume:     音量 0->1, 1.
     */
    open func output(_ bus: UInt32, volume: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        let status =  AudioUnitSetParameter(instance, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, bus, volume, inBufferOffsetInFrames)
        
        return status
    }
    
    /**
     音频单元连接
     
     - parameter    sourceUnit:             源音频单元
     - parameter    sourceOutBus:           源音频单元输出总线
     - parameter    destUnit:               目标音频单元
     - parameter    destInBus:              目标音频单元输入总线
     */
    public static func connection(_ sourceUnit: AudioUnit, sourceOutBus: UInt32, destUnit: AudioUnit, destInBus: UInt32) -> OSStatus {
        
        var connect = AudioUnitConnection(sourceAudioUnit: sourceUnit.instance, sourceOutputNumber: sourceOutBus, destInputNumber: destInBus)
        
        let status = AudioUnitSetProperty(destUnit.instance, kAudioUnitProperty_MakeConnection, kAudioUnitScope_Input, destInBus, &connect, UInt32(MemoryLayout.stride(ofValue: connect)))
        
        Print.debug("kAudioUnitProperty_MakeConnection kAudioUnitScope_Input \(status)")
        
        return status
    }
}
