//
//  ImageInput.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import UIKit
import MetalKit

public class ImageInput: ImageSource {
    public let targets = TargetContainer()
    var internalTexture: Texture?
    var hasProcessedImage: Bool = false
    public private(set) var internalImage: CGImage?

    public init(image: CGImage, smoothlyScaleOutput: Bool = false, orientation: ImageOrientation = .portrait) {
        internalImage = image
    }
    
    public convenience init(image: UIImage, smoothlyScaleOutput: Bool = false, orientation: ImageOrientation = .portrait) {
        self.init(image: image.cgImage!, smoothlyScaleOutput: smoothlyScaleOutput, orientation: orientation)
    }
    
    public func processImage(synchronously: Bool = false) {
        if let texture = internalTexture {
            if synchronously {
                self.updateTargetsWithTexture(texture)
                self.hasProcessedImage = true
            } else {
                DispatchQueue.global().async{
                    self.updateTargetsWithTexture(texture)
                    self.hasProcessedImage = true
                }
            }
        } else {
            let textureLoader = MTKTextureLoader(device: MetalRenderingDevice.shared.device)
            if synchronously {
                do {
                    let imageTexture = try textureLoader.newTexture(cgImage:internalImage!, options: [MTKTextureLoader.Option.SRGB : false])
                    internalImage = nil
                    self.internalTexture = Texture(orientation: .portrait, texture: imageTexture)
                    self.updateTargetsWithTexture(self.internalTexture!)
                    self.hasProcessedImage = true
                } catch {
                    fatalError("Failed loading image texture")
                }
            } else {
                textureLoader.newTexture(cgImage: internalImage!, options: [MTKTextureLoader.Option.SRGB: false]) { possibleTexture, error in
                    guard (error == nil) else { fatalError("Error in loading texture: \(error!)") }
                    guard let texture = possibleTexture else { fatalError("Nil texture received") }
                    self.internalImage = nil
                    self.internalTexture = Texture(orientation: .portrait, texture: texture)
                    DispatchQueue.global().async{
                        self.updateTargetsWithTexture(self.internalTexture!)
                        self.hasProcessedImage = true
                    }
                }
            }
        }
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        if hasProcessedImage {
            target.newTextureAvailable(self.internalTexture!, fromSourceIndex:atIndex)
        }
    }
}
