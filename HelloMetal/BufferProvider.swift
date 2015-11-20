//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Andrew  K. on 4/10/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class BufferProvider: NSObject {
  // 1
  let inflightBuffersCount: Int
  // 2
  private var uniformsBuffers: [MTLBuffer]
  // 3
  private var avaliableBufferIndex: Int = 0
  var avaliableResourcesSemaphore:dispatch_semaphore_t
  
  init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
    
    avaliableResourcesSemaphore = dispatch_semaphore_create(inflightBuffersCount)
    
    self.inflightBuffersCount = inflightBuffersCount
    uniformsBuffers = [MTLBuffer]()
    
    for _ in 0...inflightBuffersCount-1{
      let uniformsBuffer = device.newBufferWithLength(sizeOfUniformsBuffer, options: [])
      uniformsBuffers.append(uniformsBuffer)
    }
  }
  
  deinit{
    for _ in 0...self.inflightBuffersCount{
      dispatch_semaphore_signal(self.avaliableResourcesSemaphore)
    }
  }
  
  func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
    
    // 1
    let buffer = uniformsBuffers[avaliableBufferIndex]
    
    // 2
    let bufferPointer = buffer.contents()
    
    // 3
    memcpy(bufferPointer, modelViewMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
    memcpy(bufferPointer + sizeof(Float)*Matrix4.numberOfElements(), projectionMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
    
    // 4
    avaliableBufferIndex++
    if avaliableBufferIndex == inflightBuffersCount{
      avaliableBufferIndex = 0
    } 
    
    return buffer
  }
}
