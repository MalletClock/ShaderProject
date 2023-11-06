Shader "Unlit/Intersection"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _IntersectionColor;
            CBUFFER_END

            Varyings Vert (const Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                
                return output;
            }

            float4 Frag(const Varyings input) : SV_TARGET
            {
                float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                float4 sceneDepth = SampleSceneDepth(screenUV);
                float4 depthTexture = LinearEyeDepth(sceneDepth, _ZBufferParams);
                float4 depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);

                float4 lerpValue = pow(1 - saturate(depthTexture - depthObject),15);
                
                return lerp(_Color, _IntersectionColor, lerpValue);
            }
            ENDHLSL
        }
    }
}