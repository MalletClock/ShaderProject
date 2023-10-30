Shader "Unlit/ProximityTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PlayerPosition("Player Position", Vector) = (0, 0, 0, 0)
        _DistanceAttenuation("Player Position", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags
        { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ProximityTexturePass"
            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float3 _PlayerPosition;
            float _DistanceAttenuation;
            CBUFFER_END
            
            // input
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            // output
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            
            

            Varyings Vert (const Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }

            float4 Frag (const Varyings input) : SV_Target
            {
                //return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                const float4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));

                
                float distance = length(_PlayerPosition - input.positionWS);
                distance = saturate(1 - distance / _DistanceAttenuation);
                
                return lerp(0, color1 ,distance);
                //return distance;
            }
            ENDHLSL
        }

Pass
        {
            Name "Depth"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            
            #include "DepthPass.hlsl"
            ENDHLSL

        }

        Pass
        {
            Name "Normals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "DepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
}
