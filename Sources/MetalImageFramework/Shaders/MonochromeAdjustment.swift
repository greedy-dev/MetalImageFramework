//
//  MonochromeAdjustment.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

public class MonochromeFilter: BasicShaderOperation {
    public var intensity: Float = 1.0 { didSet { uniformSettings["intensity"] = intensity } }
    public var color: Color = Color(red: 0.6, green: 0.45, blue: 0.3, alpha: 1.0) {
        didSet { uniformSettings["filterColor"] = color }
    }
    
    public init() {
        super.init(fragmentFunctionName:"monochromeFragment", numberOfInputs:1)
        
        self.uniformSettings.colorUniformsUseAlpha = false
        intensity = 1.0
        color = Color(red:0.6, green:0.45, blue:0.3, alpha:1.0)
    }
}
