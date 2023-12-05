//
//  ShaderTypes.metal
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

#include <metal_stdlib>

using namespace metal;

constant simd::half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);

struct SingleInputVertexIO
{
    simd::float4 position [[position]];
    simd::float2 textureCoordinate [[user(texturecoord)]];
};

struct DoubleInputVertexIO
{
    simd::float4 position [[position]];
    simd::float2 textureCoordinate [[user(texturecoord)]];
    simd::float2 textureCoordinate2 [[user(texturecoord2)]];
};

