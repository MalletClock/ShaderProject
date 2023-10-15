Shader "Unlit/Phong"
{
    Properties
    {
        _Shininess("Shininess", Range(1,200)) = 20
        _Color("Color", Color) = (1, 1, 1, 1) 
    }
    SubShader
    {
        Tags
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "OmaPass2"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // input
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalsOS : NORMAL;
            };

            // output
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD01;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Shininess;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.normalWS = normalize(mul(input.normalsOS, unity_ObjectToWorld).xyz);
                output.positionWS = mul(unity_ObjectToWorld, input.positionOS);

                return output;
            }

            float4 BlinnPhong(const Varyings input) : SV_TARGET
            {
                Light mainLight = GetMainLight();
                
                half3 ambientLighting = mainLight.color *0.1f;
                half3 diffuseLighting = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                half3 halfVector = normalize(mainLight.direction + GetWorldSpaceNormalizeViewDir(input.positionWS));
                half3 specularLighting = pow(saturate(dot(input.normalWS, halfVector)), _Shininess) * mainLight.color;
                    
                return float4((ambientLighting + diffuseLighting + specularLighting) *_Color, 1);
            }
            
            float4 Frag(const Varyings input) : SV_TARGET
            {
                //return _Color;
                return BlinnPhong(input);
            }

            ENDHLSL
        }
    }
}
