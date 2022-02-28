Shader "Unlit/projector"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ProjectTex("_ProjectTex",2D) = "white"{}
    }
    SubShader
    {
        
        LOD 100

        Pass
        {
            Tags { "RenderType"="Opaque" }
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
           Pass
        {
            Tags { "RenderType"="Transparent" "Queue"="Transparent"}
            Blend One One
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
                float4 proPos : TEXCOORD1;
            };

            sampler2D _ProjectTex;
            float4 _ProjectTex_ST;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.proPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                // frac(v) 函数 ：
                //  return v - floor(v)
                // 得到的是小数部分的值
                // length（v） ：返回向量v的长度 

                // uv是 0-1的，减去0.5，则是以中心点为 原点
                //float col = frac(length(i.uv-0.5)*10);
                //float col = frac( length(i.uv-0.5)*3);
                // 伪随机
                float4 col = tex2D(_ProjectTex,i.proPos.xy/i.proPos.w);
                return fixed4(col.rgb,1);
            }
            ENDCG
        }
    }
}
