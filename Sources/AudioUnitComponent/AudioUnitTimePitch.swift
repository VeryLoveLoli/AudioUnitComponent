//
//  AudioUnitTimePitch.swift
//  
//
//  Created by 韦烽传 on 2021/6/1.
//

import Foundation
import AudioToolbox
import Print

/**
 音频音调
 */
open class AudioUnitTimePitch: AudioUnit {
    
    /// 协议
    open var delegate: AudioUnitTimePitchProtocol? {
        
        didSet {
            
            if delegate == nil {
                
                inRenderCallback.inputProc = nil
                inRenderCallback.inputProcRefCon = nil
            }
            else {
                
                addInRenderCallback()
            }
        }
    }
    
    /// 输入渲染回调
    var inRenderCallback = AURenderCallbackStruct()
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数（使用非交错浮点）
     - parameter    componentDescription:       音频设备参数
     */
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .timePitchConverter()) {
        
        super.init(streamBasicDescription, componentDescription: componentDescription)
    }
    
    /**
     输入渲染
     */
    @discardableResult func addInRenderCallback() -> OSStatus {
        
        /// 初始化渲染回调
        inRenderCallback.inputProcRefCon = AudioUnit.bridge(self)
        inRenderCallback.inputProc = { (raw, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            guard inNumberFrames > 0 else { return errno }
            guard ioData != nil else { return errno }
            
            let timePitch: AudioUnitTimePitch = AudioUnit.bridge(raw: raw)
            
            return timePitch.delegate?.audioUnit(timePitch, inNumberFrames: inNumberFrames, ioData: ioData) ?? noErr
        }
        
        /// 设置混音渲染回调 --> 总线i
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, AudioUnitElement(0), &inRenderCallback, UInt32(MemoryLayout.stride(ofValue: inRenderCallback)))
        
        Print.debug("kAudioUnitProperty_SetRenderCallback kAudioUnitScope_Input \(status)")
        
        return status
    }
    
    // MARK: - AUNewTimePitch
    
    /**
     音调
     
     - parameter    value:      -2400 -> 2400, 1.0 `0:不变` `<0:低音调（男声）` `>0:高音调（女声）`
     */
    func pitch(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     比率
     
     - parameter    value:      1/32 -> 32.0, 1.0
     */
    func rate(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kNewTimePitchParam_Rate, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     重叠
     
     - parameter    value:      3.0 -> 32.0, 8.0
     */
    func overlap(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kNewTimePitchParam_Overlap, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     峰值锁定
     
     - parameter    value:      0->1, 1
     */
    func enablePeakLocking(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kNewTimePitchParam_EnablePeakLocking, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
}
