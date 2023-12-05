//
//  ShaderTypes.hpp
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

#ifndef ShaderTypes_hpp
#define ShaderTypes_hpp

constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct DoubleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};

#endif /* ShaderTypes_h */
