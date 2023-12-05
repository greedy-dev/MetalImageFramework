//
//  BasicShaderOperation.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import Metal

public func defaultVertexFunctionNameForInputs(_ inputCount: UInt) -> String {
    switch inputCount {
    case 1:
        return "oneInputVertex"
    case 2:
        return "twoInputVertex"
    default:
        return "oneInputVertex"
    }
}

open class BasicShaderOperation: ImageProcessingOperation {
    
    public let maximumInputs: UInt
    public let sources = SourceContainer()
    public let targets = TargetContainer()
    
    public var activatePassthroughOnNextFrame: Bool = false
    public var uniformSettings: ShaderUniformSettings
    
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String
    var inputTextures = [UInt: Texture]()
    let textureInputSemaphore = DispatchSemaphore(value: 1)
    var useNormalizedTextureCoordinates = true
    var metalPerformanceShaderPathway: ((MTLCommandBuffer, [UInt: Texture], Texture) -> ())?

    public init(vertexFunctionName: String? = nil, fragmentFunctionName: String, numberOfInputs: UInt = 1, operationName: String = #file) {
        self.maximumInputs = numberOfInputs
        self.operationName = operationName
        
        let concreteVertexFunctionName = vertexFunctionName ?? defaultVertexFunctionNameForInputs(numberOfInputs)
        let (pipelineState, lookupTable) = generateRenderPipelineState(device: MetalRenderingDevice.shared, vertexFunctionName:concreteVertexFunctionName, fragmentFunctionName:fragmentFunctionName, operationName:operationName)
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable)
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        // TODO: Finish implementation later
    }
    
    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
        defer {
            textureInputSemaphore.signal()
        }
        
        inputTextures[fromSourceIndex] = texture
        
        if (UInt(inputTextures.count) >= maximumInputs) || activatePassthroughOnNextFrame {
            let outputWidth: Int
            let outputHeight: Int
            
            let firstInputTexture = inputTextures[0]!
            if firstInputTexture.orientation.rotationNeeded(for:.portrait).flipsDimensions() {
                outputWidth = firstInputTexture.texture.height
                outputHeight = firstInputTexture.texture.width
            } else {
                outputWidth = firstInputTexture.texture.width
                outputHeight = firstInputTexture.texture.height
            }

            if uniformSettings.usesAspectRatio {
                let outputRotation = firstInputTexture.orientation.rotationNeeded(for:.portrait)
                uniformSettings["aspectRatio"] = firstInputTexture.aspectRatio(for: outputRotation)
            }
            
            guard let commandBuffer = MetalRenderingDevice.shared.commandQueue.makeCommandBuffer() else { return }

            let outputTexture = Texture(
                device: MetalRenderingDevice.shared.device,
                orientation: .portrait,
                width: outputWidth,
                height: outputHeight
            )
            
            guard !activatePassthroughOnNextFrame else {
                activatePassthroughOnNextFrame = false
                
                textureInputSemaphore.signal()
                updateTargetsWithTexture(outputTexture)
                _ = textureInputSemaphore.wait(timeout: DispatchTime.distantFuture)

                return
            }
            
            if let alternateRenderingFunction = metalPerformanceShaderPathway {
                var rotatedInputTextures: [UInt: Texture]
                if (firstInputTexture.orientation.rotationNeeded(for: .portrait) != .noRotation) {
                    let rotationOutputTexture = Texture(device: MetalRenderingDevice.shared.device, orientation: .portrait, width: outputWidth, height: outputHeight)
                    guard let rotationCommandBuffer = MetalRenderingDevice.shared.commandQueue.makeCommandBuffer() else { return }
                    rotationCommandBuffer.renderQuad(pipelineState: MetalRenderingDevice.shared.passthroughRenderState, uniformSettings: uniformSettings, inputTextures: inputTextures, useNormalizedTextureCoordinates: useNormalizedTextureCoordinates, outputTexture: rotationOutputTexture)
                    rotationCommandBuffer.commit()
                    rotatedInputTextures = inputTextures
                    rotatedInputTextures[0] = rotationOutputTexture
                } else {
                    rotatedInputTextures = inputTextures
                }
                alternateRenderingFunction(commandBuffer, rotatedInputTextures, outputTexture)
            } else {
                internalRenderFunction(commandBuffer: commandBuffer, outputTexture: outputTexture)
            }
            commandBuffer.commit()
            
            textureInputSemaphore.signal()
            updateTargetsWithTexture(outputTexture)
            let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
        }
    }
    
    func internalRenderFunction(commandBuffer: MTLCommandBuffer, outputTexture: Texture) {
        commandBuffer.renderQuad(pipelineState: renderPipelineState, uniformSettings: uniformSettings, inputTextures: inputTextures, useNormalizedTextureCoordinates: useNormalizedTextureCoordinates, outputTexture: outputTexture)
    }
}

