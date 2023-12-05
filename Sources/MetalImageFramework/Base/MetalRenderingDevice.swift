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
            let frameworkBundle = Bundle(for: MetalRenderingDevice.self)
            let execPath = ProcessInfo.processInfo.arguments.first!
            let execURL = URL(fileURLWithPath: execPath)
            let execRootURL = execURL.deletingLastPathComponent()
            let libraryURL = execRootURL.appendingPathComponent("MetalImageFramework_MetalImageFramework.bundle/default.metallib")
            self.shaderLibrary = try device.makeLibrary(URL: libraryURL)
        } catch {
            fatalError("Could not load library")
        }
    }
}
