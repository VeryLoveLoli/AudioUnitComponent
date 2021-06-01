//
//  AudioComponentDescription.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox

extension AudioComponentDescription {
    
    /**
     音频设备参数
     
     - parameter    type:       组件类型
     - parameter    subType:    子组件类型
     */
    public static func acd(_ type: OSType, subType: OSType) -> AudioComponentDescription {
        
        var componentDescription = AudioComponentDescription()
        
        componentDescription.componentType = type
        componentDescription.componentSubType = subType
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        
        return componentDescription
    }
    
    /**
     远程IO音频设备参数
     */
    public static func remoteIO() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_Output, subType: kAudioUnitSubType_RemoteIO)
    }
    
    /**
     语音处理IO音频设备参数（增强版`RemoteIO`，有消除回声效果，一般用于语音通话）
     */
    public static func voiceProcessingIO() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_Output, subType: kAudioUnitSubType_VoiceProcessingIO)
    }
    
    /**
     通用输出音频设备参数
     */
    public static func genericOutput() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_Output, subType: kAudioUnitSubType_GenericOutput)
    }
    
    /**
     多通道混音器音频设备参数
     */
    public static func multiChannelMixer() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_Mixer, subType: kAudioUnitSubType_MultiChannelMixer)
    }
    
    /**
     音调转换器音频设备参数
     */
    public static func timePitchConverter() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_FormatConverter, subType: kAudioUnitSubType_NewTimePitch)
    }
    
    /**
     音响特效音频设备参数
     */
    public static func reverb2Effect() -> AudioComponentDescription {
        
        return acd(kAudioUnitType_Effect, subType: kAudioUnitSubType_Reverb2)
    }
}
