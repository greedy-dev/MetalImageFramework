//
//  Contrast.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import Foundation

public class ContrastAdjustment: BasicShaderOperation {
    public var contrast: Float = 1.0 { didSet { uniformSettings["contrast"] = contrast } }
    
    public init() {
        super.init(fragmentFunctionName: "contrastFragment", numberOfInputs: 1)
        
        contrast = 1.0
    }
}
