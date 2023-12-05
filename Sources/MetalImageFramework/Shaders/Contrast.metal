//
//  Contrast.metal
//  MetalImageFramework
//
//  Created by Denis on 12/1/23.
//

#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

typedef struct
{
    float contrast;
} ContrastUniform;

fragment half4 contrastFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant ContrastUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4(((color.rgb - half3(0.5)) * uniform.contrast + half3(0.5)), color.a);
}