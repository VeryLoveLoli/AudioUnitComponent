//
//  AudioUnitRecorder.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频录制器
 */
open class AudioUnitRecorder: AudioUnitIO {
    
    /// 协议
    open var delegate: AudioUnitRecorderProtocol?
    /// 缓冲数据列表
    var bufferList = AudioBufferList()
    
    /**
     初始化
     
     - parameter    streamBasicDescription:     音频流参数
     - parameter    componentDescription:       音频设备参数
     */
    public override init?(_ streamBasicDescription: AudioStreamBasicDescription, componentDescription: AudioComponentDescription = .remoteIO()) {
        
        super.init(streamBasicDescription, componentDescription: componentDescription)
        
        var status: OSStatus = noErr
        
        status = microphone()
        
        guard status == noErr else { return nil }
        
        /// 回调函数
        var renderCallbackStruct = AURenderCallbackStruct(inputProc: { (raw, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData) -> OSStatus in
            
            var status: OSStatus = errno
            
            /// 帧数
            guard inNumberFrames > 0 else { return status }
            
            /// inputProcRefCon传输进来的对象
            let recorder: AudioUnitRecorder = AudioUnit.bridge(raw: raw)
            
            /// 帧字节大小
            let size = recorder.basic.mBytesPerFrame
            /// 通道数
            let channels = recorder.basic.mChannelsPerFrame
            
            /// 缓冲区数量（只有一个）
            recorder.bufferList.mNumberBuffers = 1
            recorder.bufferList.mBuffers.mNumberChannels = channels
            recorder.bufferList.mBuffers.mDataByteSize = size * inNumberFrames
            /// 缓冲区数据（开辟内存 calloc 会重置内存数据 malloc 不会重置）
            recorder.bufferList.mBuffers.mData = calloc(Int(inNumberFrames), Int(size))
            
            /// 渲染（写入音频数据）
            status = AudioUnitRender(recorder.instance, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, &recorder.bufferList)
            
            guard status == noErr else { return status }
            
            /// 回调音频数据
            recorder.delegate?.audioUnit(recorder, inNumberFrames: inNumberFrames, ioData: &recorder.bufferList)
            
            /// 释放内存
            free(recorder.bufferList.mBuffers.mData)
            recorder.bufferList.mBuffers.mData = nil
            
            return status
            
        }, inputProcRefCon: AudioUnit.bridge(self))
        
        /// 设置回调输出 ---> 总线1
        status = AudioUnitSetProperty(instance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, element_1, &renderCallbackStruct, UInt32(MemoryLayout.stride(ofValue: renderCallbackStruct)))
        
        Print.debug("kAudioOutputUnitProperty_SetInputCallback kAudioUnitScope_Global \(status)")
        
        guard status == noErr else { return nil }
        
        var flag: UInt32 = 0
        
        /// 禁用缓冲区分配 使用自定义的
        status = AudioUnitSetProperty(instance, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, element_1, &flag, UInt32(MemoryLayout.stride(ofValue: flag)))
        
        Print.debug("kAudioUnitProperty_ShouldAllocateBuffer kAudioUnitScope_Output \(status)")
        
        guard status == noErr else { return nil }
    }
}
