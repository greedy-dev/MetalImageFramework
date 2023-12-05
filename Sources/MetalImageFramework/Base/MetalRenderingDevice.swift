//
//  MetalRenderingDevice.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import Metal
import MetalPerformanceShaders

public class MetalRenderingDevice {
    public static let shared = MetalRenderingDevice()
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let shaderLibrary: MTLLibrary
    
    lazy var passthroughRenderState: MTLRenderPipelineState = {
        let (pipelineState, _) = generateRenderPipelineState(device:self, vertexFunctionName:"oneInputVertex", fragmentFunctionName:"passthroughFragment", operationName:"Passthrough")
        return pipelineState
    }()

    lazy var colorSwizzleRenderState: MTLRenderPipelineState = {
        let (pipelineState, _) = generateRenderPipelineState(device:self, vertexFunctionName:"oneInputVertex", fragmentFunctionName:"colorSwizzleFragment", operationName:"ColorSwizzle")
        return pipelineState
    }()

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {fatalError("Could not create Metal Device")}
        self.device = device
        
        guard let queue = self.device.makeCommandQueue() else {fatalError("Could not create command queue")}
        self.commandQueue = queue
        
        do {
            #if SWIFT_PACKAGE
            let bundleUrl = Bundle.module.bundleURL
            let libUrl = bundleUrl.appending(component: "default.metallib")
            self.shaderLibrary = try device.makeLibrary(URL: libUrl)
            #else
            let bundleUrl = Bundle(for: MetalRenderingDevice.self).bundleURL
            let libUrl = bundleUrl.appending(component: "default.metallib")
            self.shaderLibrary = try device.makeLibrary(URL: libUrl)
            #endif
        } catch {
            fatalError("Could not load library")
        }
    }
}
