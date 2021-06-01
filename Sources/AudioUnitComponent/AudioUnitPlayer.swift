//
//  AudioUnitPlayer.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频播放器
 */
open class AudioUnitPlayer: AudioUnitIO {
    
    /// 协议
    open var delegate: AudioUnitPlayerProtocol?
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数
     - parameter    componentDescription:       音频设备参数
     */
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .remoteIO()) {
        
        super.init(streamBasicDescription, componentDescription: componentDescription)
        
        var status: OSStatus = noErr
        
        /// 渲染输入
        var renderCallbackStruct = AURenderCallbackStruct(inputProc: { (raw, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            /// 帧数
            guard inNumberFrames > 0 else { return errno }
            guard ioData != nil else { return errno }
            
            let player: AudioUnitPlayer = AudioUnit.bridge(raw: raw)
            
            /// 回调音频数据
            return player.delegate?.audioUnit(player, inNumberFrames: inNumberFrames, ioData: ioData!) ?? noErr
            
        }, inputProcRefCon: AudioUnit.bridge(self))
        
        /// 设置回调输入 ---> 总线0
        status = AudioUnitSetProperty(instance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, element_0, &renderCallbackStruct, UInt32(MemoryLayout.stride(ofValue: renderCallbackStruct)))
        
        Print.debug("kAudioUnitProperty_SetRenderCallback kAudioUnitScope_Global \(status)")
        
        guard status == noErr else { return nil }
        
        /// 添加渲染通知
        status = AudioUnitAddRenderNotify(instance, { (raw, inActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            /// 渲染后
            if inActionFlags.pointee.contains(.unitRenderAction_PostRender) {
                
                guard inNumberFrames > 0 else { return errno }
                guard ioData != nil else { return errno }
                
                let player: AudioUnitPlayer = AudioUnit.bridge(raw: raw)
                
                return player.delegate?.audioUnit(player, outNumberFrames: inNumberFrames, ioData: ioData) ?? noErr
            }
            
            return noErr
            
        }, AudioUnit.bridge(self))
        
        Print.debug("AudioUnitAddRenderNotify \(status)")
        
        guard status == noErr else { return nil }
    }
}
