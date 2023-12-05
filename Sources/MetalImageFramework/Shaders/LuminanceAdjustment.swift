//
//  LuminanceAdjustment.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

import Foundation

public class LuminanceAdjustment: BasicShaderOperation {
    public init() {
        super.init(fragmentFunctionName: "luminanceFragment", numberOfInputs: 1)
    }
}
