//
//  ImageOutput.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import UIKit
import Metal

public enum ImageFileFormat {
    case png
    case jpeg
}

public class ImageOutput: ImageConsumer {
    public var encodedImageAvailableCallback: ((Data) -> ())?
    public var encodedImageFormat: ImageFileFormat = .png
    public var imageAvailableCallback: ((UIImage) -> ())?
    public var onlyCaptureNextFrame: Bool = true
    public var keepImageAroundForSynchronousCapture: Bool = false
    var storedTexture: Texture?
    
    public let sources = SourceContainer()
    public let maximumInputs: UInt = 1
    var url: URL!
    
    public init() {}
    
    public func saveNextFrameToURL(_ url: URL, format: ImageFileFormat) {
        onlyCaptureNextFrame = true
        encodedImageFormat = format
        self.url = url
        encodedImageAvailableCallback = {imageData in
            do {
                try imageData.write(to: self.url, options:.atomic)
            } catch {
                print("Couldn't save image: \(error)")
            }
        }
    }
    
    public func newTextureAvailable(_ texture:Texture, fromSourceIndex:UInt) {
        if keepImageAroundForSynchronousCapture {
            storedTexture = texture
        }
        
        if let imageCallback = imageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)

            imageCallback(image)
            
            if onlyCaptureNextFrame {
                imageAvailableCallback = nil
            }
        }
        
        if let imageCallback = encodedImageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            
            let imageData:Data
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
            switch encodedImageFormat {
            case .png: imageData = image.pngData()!
            case .jpeg: imageData = image.jpegData(compressionQuality: 0.8)!
            }
            imageCallback(imageData)
            
            if onlyCaptureNextFrame {
                encodedImageAvailableCallback = nil
            }
        }
    }
}

public extension ImageSource {
    func saveNextFrameToURL(_ url: URL, format: ImageFileFormat) {
        let pictureOutput = ImageOutput()
        pictureOutput.saveNextFrameToURL(url, format:format)
        self => pictureOutput
    }
}

public extension UIImage {
    func filterWithOperation<T:ImageProcessingOperation>(_ operation:T) -> UIImage {
        return filterWithPipeline{ input, output in
            input => operation => output
        }
    }
    
    func filterWithPipeline(_ pipeline: (ImageInput, ImageOutput) -> ()) -> UIImage {
        let picture = ImageInput(image:self)
        var outputImage: UIImage?
        let pictureOutput = ImageOutput()
        pictureOutput.onlyCaptureNextFrame = true
        pictureOutput.imageAvailableCallback = { image in
            outputImage = image
        }
        pipeline(picture, pictureOutput)
        picture.processImage(synchronously:true)
        return outputImage!
    }
}
