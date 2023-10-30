Shader "Unlit/ProximityDeform"
{
    Properties
    {
        _Color("Main Color", Color) = (1,1,1,1)
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
            Name "ProximityDeformPass"
            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float3 _PlayerPosition;
            float _DistanceAttenuation;
            CBUFFER_END
            
            // input
            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            // output
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };
            
            

            Varyings Vert (const Attributes input)
            {
                Varyings output;
                const float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

                float3 dir = positionWS - _PlayerPosition;
                float distance = length(dir);
                distance = saturate(1 - distance / _DistanceAttenuation);

                output.positionHCS = TransformWorldToHClip(positionWS + normalize(dir) * distance);
                
                return output;
            }

            float4 Frag (const Varyings input) : SV_Target
            {
                return _Color;
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
