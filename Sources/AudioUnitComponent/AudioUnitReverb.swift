//
//  AudioUnitReverb.swift
//  
//
//  Created by 韦烽传 on 2021/6/1.
//

import Foundation
import AudioToolbox
import Print

/**
 音频音响
 */
open class AudioUnitReverb: AudioUnit {
    
    /// 协议
    open var delegate: AudioUnitReverbProtocol? {
        
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
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .reverb2Effect()) {
        
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
            
            let reverb: AudioUnitReverb = AudioUnit.bridge(raw: raw)
            
            return reverb.delegate?.audioUnit(reverb, inNumberFrames: inNumberFrames, ioData: ioData) ?? noErr
        }
        
        /// 设置混音渲染回调 --> 总线i
        let status = AudioUnitSetProperty(instance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, AudioUnitElement(0), &inRenderCallback, UInt32(MemoryLayout.stride(ofValue: inRenderCallback)))
        
        Print.debug("kAudioUnitProperty_SetRenderCallback kAudioUnitScope_Input \(status)")
        
        return status
    }
    
    // MARK: - Reverb2
    
    /**
     干湿比
     
     - parameter    value:      0->100, 100
     */
    open func dryWetMix(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     增益
     
     - parameter    value:      -20->20, 0
     */
    open func gain(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_Gain, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     最小延迟时间
     
     - parameter    value:      0.0001->1.0, 0.008
     */
    open func minDelayTime(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     最大延迟时间
     
     - parameter    value:      0.0001->1.0, 0.050
     */
    open func maxDelayTime(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     `0Hzt` 衰减时间（空旷）
     `kReverb2Param_DecayTimeAt0Hz / kReverb2Param_DecayTimeAtNyquist`
     
     - parameter    value:      0.001->20.0, 1.0
     */
    open func decayTimeAt0Hz(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     `Nyquist` 衰减时间（空旷）
     `kReverb2Param_DecayTimeAt0Hz / kReverb2Param_DecayTimeAtNyquist`
     
     - parameter    value:      0.001->20.0, 0.5
     */
    open func decayTimeAtNyquist(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
    
    /**
     随机反射
     
     - parameter    value:      0->1000
     */
    open func randomizeReflections(_ value: AudioUnitParameterValue, inBufferOffsetInFrames: UInt32 = 0) -> OSStatus {
        
        return AudioUnitSetParameter(instance, kReverb2Param_RandomizeReflections, kAudioUnitScope_Global, 0, value, inBufferOffsetInFrames)
    }
}
