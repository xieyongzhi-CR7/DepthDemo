Shader "Unlit/DrawLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("LineColor",Color) = (0,0,0,0)
        [hideIninspector]_HitUV("HitUV",vector) = (0,0,0,0)
        _powSize("pow size",Range(0,10000)) = 5000
        _Strength("Strength",Range(0,60)) = 1
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _powSize;
            float _Strength;
vector _HitUV;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float draw = pow(saturate(1 - distance(i.uv,_HitUV.xy)),500/_powSize);
                fixed4 drawCol = _Color * (draw * _Strength);
                
                return col + drawCol;
            }
            ENDCG
        }
    }
}
