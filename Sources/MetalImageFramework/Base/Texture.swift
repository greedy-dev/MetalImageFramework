//
//  Texture.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import Metal
import UIKit

public class Texture {
    public var orientation: ImageOrientation
    
    public let texture: MTLTexture
    
    public init(orientation: ImageOrientation, texture: MTLTexture) {
        self.orientation = orientation
        self.texture = texture
    }
    
    public init(
        device: MTLDevice,
        orientation: ImageOrientation,
        pixelFormat: MTLPixelFormat = .bgra8Unorm,
        width: Int,
        height: Int,
        mipmapped: Bool = false
    ) {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: width,
                                                                         height: height,
                                                                         mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let newTexture = MetalRenderingDevice.shared.device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Could not create texture of size: (\(width), \(height))")
        }

        self.orientation = orientation
        self.texture = newTexture
    }
}

extension Texture {
    func textureCoordinates(for outputOrientation: ImageOrientation, normalized: Bool) -> [Float] {
        let inputRotation = self.orientation.rotationNeeded(for:outputOrientation)

        let xLimit:Float
        let yLimit:Float
        if normalized {
            xLimit = 1.0
            yLimit = 1.0
        } else {
            xLimit = Float(self.texture.width)
            yLimit = Float(self.texture.height)
        }
        
        switch inputRotation {
        case .noRotation: return [0.0, 0.0, xLimit, 0.0, 0.0, yLimit, xLimit, yLimit]
        case .rotateCounterclockwise: return [0.0, yLimit, 0.0, 0.0, xLimit, yLimit, xLimit, 0.0]
        case .rotateClockwise: return [xLimit, 0.0, xLimit, yLimit, 0.0, 0.0, 0.0, yLimit]
        case .rotate180: return [xLimit, yLimit, 0.0, yLimit, xLimit, 0.0, 0.0, 0.0]
        case .flipHorizontally: return [xLimit, 0.0, 0.0, 0.0, xLimit, yLimit, 0.0, yLimit]
        case .flipVertically: return [0.0, yLimit, xLimit, yLimit, 0.0, 0.0, xLimit, 0.0]
        case .rotateClockwiseAndFlipVertically: return [0.0, 0.0, 0.0, yLimit, xLimit, 0.0, xLimit, yLimit]
        case .rotateClockwiseAndFlipHorizontally: return [xLimit, yLimit, xLimit, 0.0, 0.0, yLimit, 0.0, 0.0]
        }
    }
    
    func aspectRatio(for rotation: Rotation) -> Float {
        return Float(self.texture.height) / Float(self.texture.width)
    }
}

extension Texture {
    func cgImage() -> CGImage {
        guard let commandBuffer = MetalRenderingDevice.shared.commandQueue.makeCommandBuffer() else {
            fatalError("Could not create command buffer on image rendering.")
        }
        
        let outputTexture = Texture(
            device: MetalRenderingDevice.shared.device,
            orientation: self.orientation,
            width: self.texture.width,
            height: self.texture.height
        )
        
        commandBuffer.renderQuad(
            pipelineState: MetalRenderingDevice.shared.colorSwizzleRenderState,
            uniformSettings: nil,
            inputTextures: [0: self],
            useNormalizedTextureCoordinates: true,
            outputTexture: outputTexture
        )
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Generate CGImageRef from texture bytes
        let imageByteSize = texture.height * texture.width * 4
        let outputBytes = UnsafeMutablePointer<UInt8>.allocate(capacity:imageByteSize)
        outputTexture.texture.getBytes(
            outputBytes,
            bytesPerRow: MemoryLayout<UInt8>.size * texture.width * 4,
            bytesPerImage:0,
            from: MTLRegionMake2D(0, 0, texture.width, texture.height),
            mipmapLevel: 0,
            slice: 0
        )
        
        guard let dataProvider = CGDataProvider(
            dataInfo: nil,
            data: outputBytes,
            size: imageByteSize,
            releaseData: dataProviderReleaseCallback
        ) else {
            fatalError("Could not create CGDataProvider")
        }
        
        let defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB()
        
        return CGImage(
            width: texture.width,
            height: texture.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: 4 * texture.width,
            space: defaultRGBColorSpace,
            bitmapInfo: CGBitmapInfo(
                rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
            ),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
    }
}

func dataProviderReleaseCallback(_ context: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) {
    data.deallocate()
}
