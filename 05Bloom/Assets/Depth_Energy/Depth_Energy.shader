Shader "Unlit/Depth_Energy"
{
    Properties
    {
        _MainColor ("Texture", color) = (1,0,0,1)
        //_IntersectionCol("intersection col",color) = (1,0,0,1)
        //_EdgeWidth("edge width",range(0,10)) = 1
        _RimPower("_RimPower",range(0,1)) = 1
        _IntersectionPower(" intersection power",range(0,0.5))= 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 scrProj:TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float eyeZ : TEXCOORD3;
                float3 worldNormal : TEXCOORD4;
            };

            float4 _MainColor;
            sampler2D _CameraDepthTexture;
            float _RimPower;
            float _IntersectionPower;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                COMPUTE_EYEDEPTH(o.eyeZ);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.scrProj = ComputeScreenPos(v.vertex);
                o.worldNormal = UnityObjectToWorldDir(v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = i.worldPos;
                float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldLight =normalize(UnityWorldSpaceLightDir(worldPos));
                float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrProj.xy/i.scrProj.w));

                float rim = 1 - saturate(dot(i.worldNormal,worldView)) * _RimPower;

                float intersect = (1 - (screenZ - i.eyeZ)) * _IntersectionPower;
                float v = max(rim,intersect);
                return _MainColor * v;
            }
            ENDCG
        }
    }
}
