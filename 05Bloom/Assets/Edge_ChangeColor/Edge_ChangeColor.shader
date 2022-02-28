Shader "Custom/ChangeColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            sampler2D _MainTex;
            // 在此图中，xy存储的是法线信息；zw存储的是深度信息；
            sampler2D _CameraDepthNormalsTexture;
            float4 _MainTex_TexelSize;
            float4 _EdgeColor;
            float4 _NoEdgeColor;
            float4 _Sensitivity;
            float _SampleDistance;

            //
            //
            float _testChangeData;
            //判断两个点之间是否有边
            half checkEdge(float4 center1,float4 center2)
            {
                float2 normal1 = center1.xy;
                float d1 = DecodeFloatRG(center1.zw);
                float2 normal2 = center2.xy;
                // 将像素中的颜色值，转化为float
                float d2 = DecodeFloatRG(center2.zw);
                float2 normalDiff = abs(normal1 - normal2) * _Sensitivity.x;
                // 法线差值 大于0.1，变换明显，作为边
                int isSamplenormal = (normalDiff.x + normalDiff.y) < 0.1;
                // 深度的差值，大于0.1，变换明显，作为边
                float diffDepth = abs(d1-d2) * _Sensitivity.y;
                int isSampleDepth = diffDepth < 0.1;
                // 法线或者深度，有一个符合 >0.1,则作为边
                return isSamplenormal * isSampleDepth ? 1.0 : 0.0;
            }
    ENDCG

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance;
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance;
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance;
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance;
                o.uv[4] = v.uv;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[0]);
                fixed4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
                fixed4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
                fixed4 sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
                float edge = 1.0;
                edge *= checkEdge(sample1,sample2);
                edge *= checkEdge(sample3,sample4);
                float4 edgeCol = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
                float4 bgCol = lerp(_EdgeColor,_NoEdgeColor,edge);
                return fixed4(edgeCol.rgb + bgCol.rgb,1);
            }
            ENDCG
        }
    }
}
