//
//  MetalImageView.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import MetalKit

public class MetalImageView: MTKView, ImageConsumer {
    public let sources = SourceContainer()
    public let maximumInputs: UInt = 1
    var currentTexture: Texture?
    var renderPipelineState: MTLRenderPipelineState!
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: MetalRenderingDevice.shared.device)
        
        commonInit()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        framebufferOnly = false
        autoResizeDrawable = true
        
        self.device = MetalRenderingDevice.shared.device
        
        let (pipelineState, _) = generateRenderPipelineState(device: MetalRenderingDevice.shared, vertexFunctionName: "oneInputVertex", fragmentFunctionName: "passthroughFragment", operationName: "RenderView")
        self.renderPipelineState = pipelineState
        
        enableSetNeedsDisplay = false
        isPaused = true
    }
    
    public func newTextureAvailable(_ texture:Texture, fromSourceIndex:UInt) {
        self.drawableSize = CGSize(width: texture.texture.width, height: texture.texture.height)
        currentTexture = texture
        self.draw()
    }
    
    public override func draw(_ rect:CGRect) {
        if let currentDrawable = self.currentDrawable, let imageTexture = currentTexture {
            let commandBuffer = MetalRenderingDevice.shared.commandQueue.makeCommandBuffer()
            
            let outputTexture = Texture(orientation: .portrait, texture: currentDrawable.texture)
            commandBuffer?.renderQuad(pipelineState: renderPipelineState, inputTextures: [0:imageTexture], outputTexture: outputTexture)
            
            commandBuffer?.present(currentDrawable)
            commandBuffer?.commit()
        }
    }
}


