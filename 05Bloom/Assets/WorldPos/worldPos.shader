Shader "custom/worldPos"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 interpoalteRay : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4x4 _InterpolateRay;
            sampler2D _CameraDepthTexture;

            float _FogStart;
            float _FogEnd;
            float _FogDensity;
            float4 _FogCol;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                float2 uv = o.uv;
                int index = 0;
                if (uv.x < 0.5 && uv.y < 0.5)
                {
                    index = 0;
                }
                else if (uv.x > 0.5 && uv.y < 0.5)
                {
                    index = 1;
                }
                else if (uv.x > 0.5 && uv.y > 0.5)
                {
                    index = 2;
                }
                else if (uv.x < 0.5 && uv.y > 0.5)
                {
                    index = 3;
                }
                o.interpoalteRay = _InterpolateRay[index];
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               
                UNITY_APPLY_FOG(i.fogCoord, col);
                float depth =Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv));
                float3 worldPos = _WorldSpaceCameraPos + depth * i.interpoalteRay;
                float fogD = (worldPos.y - _FogStart) /  (_FogEnd - _FogStart);
                fogD = saturate(_FogDensity * fogD);
                
                float4 mainCol = tex2D(_MainTex,i.uv);
                float4 finalCol = lerp(_FogCol,mainCol,fogD);
                
                
                return finalCol;
            }
            ENDCG
        }
    }
}
