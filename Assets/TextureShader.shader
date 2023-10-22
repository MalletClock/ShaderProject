Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondaryTex ("Texture", 2D) = "white" {}
        _ScrollSpeeds ("ScrollSpeeds", Vector) = (0, 0, 0, 0)
        _Blend ("Blend Value", Range(0,1)) = 0
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
            Name "TexturePass"
            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // input
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            // output
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };
            
            TEXTURE2D(_MainTex);
            TEXTURE2D(_SecondaryTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecondaryTex);
            float4 _ScrollSpeeds;
            float _Blend;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            CBUFFER_END

            Varyings Vert (const Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv * _MainTex_ST.xy + (_MainTex_ST.zw + _Time * _ScrollSpeeds);
                
                return output;
            }

            float4 Frag (const Varyings input) : SV_Target
            {
                float4 MainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                float4 SecondaryColor = SAMPLE_TEXTURE2D(_SecondaryTex, sampler_SecondaryTex, input.uv);
                // sample the texture
                return lerp(MainColor, SecondaryColor, _Blend);
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
