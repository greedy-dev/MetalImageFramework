//
//  InvertColor.metal
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

fragment half4 invertColorFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4((1.0 - color.rgb), color.a);
}
