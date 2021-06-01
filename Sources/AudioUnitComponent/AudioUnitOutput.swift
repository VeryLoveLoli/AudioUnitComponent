//
//  AudioUnitOutput.swift
//  
//
//  Created by 韦烽传 on 2021/5/31.
//

import Foundation
import AudioToolbox

/**
 音频输出
 */
open class AudioUnitOutput: AudioUnit {
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数
     - parameter    componentDescription:       音频设备参数
     */
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .genericOutput()) {
        
        super.init(streamBasicDescription, componentDescription: componentDescription)
        
        let status = output(0, asbd: basic)
        
        guard status == noErr else { return nil }
    }
}
