//
//  AudioUnitMixer.swift
//  
//
//  Created by 韦烽传 on 2021/5/31.
//

import Foundation
import AudioToolbox
import Print

/**
 音频混音器
 */
open class AudioUnitMixer: AudioUnit {
    
    /// 协议
    open var delegate: AudioUnitMixerProtocol?
    
    /// 输入渲染回调
    var inRenderCallback = AURenderCallbackStruct()
    
    /**
     总线数
     */
    open var busCount: Int {
        
        get {
            
            return Int(getBusCount() ?? 0)
        }
        
        set {
            
            setBus(UInt32(newValue))
        }
    }
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数
     - parameter    componentDescription:       音频设备参数
     */
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .multiChannelMixer()) {
        
        super.init(streamBasicDescription, componentDescription: componentDescription)
        
        /// 初始化渲染回调
        inRenderCallback.inputProcRefCon = AudioUnit.bridge(self)
        inRenderCallback.inputProc = { (raw, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            guard inNumberFrames > 0 else { return errno }
            guard ioData != nil else { return errno }
            
            let mixer: AudioUnitMixer = AudioUnit.bridge(raw: raw)
            
            return mixer.delegate?.audioUnit(mixer, inBusNumber: inOutputBusNumber, inNumberFrames: inNumberFrames, ioData: ioData) ?? noErr
        }
        
        var status = output(0, asbd: basic)
        guard status == noErr else { return nil }
        
        /// 添加渲染通知
        status = AudioUnitAddRenderNotify(instance, { (raw, inActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            /// 渲染后
            if inActionFlags.pointee.contains(.unitRenderAction_PostRender) {
                
                guard inNumberFrames > 0 else { return errno }
                guard ioData != nil else { return errno }
                
                let mixer: AudioUnitMixer = AudioUnit.bridge(raw: raw)
                
                return mixer.delegate?.audioUnit(mixer, outBusNumber: inOutputBusNumber, inNumberFrames: inNumberFrames, ioData: ioData) ?? noErr
            }
            
            return noErr
            
        }, AudioUnit.bridge(self))
        
        Print.debug("AudioUnitAddRenderNotify \(status)")
        
        guard status == noErr else { return nil }
    }
    
    /**
     设置总线
     
     - parameter    count:  数量
     */
    @discardableResult open func setBus(_ count: UInt32) -> OSStatus {
        
        var value: UInt32 = UInt32(count)
        let size = UInt32(MemoryLayout.stride(ofValue: value))
        
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &value, size)
        
        Print.debug("kAudioUnitProperty_ElementCount kAudioUnitScope_Input \(status)")
        
        return status
    }
    
    /**
     获取总线数
     */
    open func getBusCount() -> UInt32? {
        
        var value: UInt32 = 0
        var size = UInt32(MemoryLayout.stride(ofValue: value))
        
        let status = AudioUnitGetProperty(instance, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &value, &size)
        
        Print.debug("kAudioUnitProperty_ElementCount kAudioUnitScope_Input \(status)")
        
        guard status == noErr else { return nil }
        
        return value
    }
    
    /**
     输入渲染
     
     - parameter    bus:    总线
     */
    open func inRenderCallback(_ bus: UInt32) -> OSStatus {
        
        /// 设置混音渲染回调 --> 总线i
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, AudioUnitElement(bus), &inRenderCallback, UInt32(MemoryLayout.stride(ofValue: inRenderCallback)))
        
        Print.debug("kAudioUnitProperty_SetRenderCallback kAudioUnitScope_Input AudioUnitElement_\(bus) \(status)")
        
        return status
    }
}
