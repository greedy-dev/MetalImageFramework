//
//  InvertColor.swift
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

public class InvertColor: BasicShaderOperation {
    public init() {
        super.init(fragmentFunctionName:"invertColorFragment", numberOfInputs:1)
    }
}
