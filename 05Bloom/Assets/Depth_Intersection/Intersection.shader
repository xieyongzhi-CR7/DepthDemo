Shader "Hidden/Intersection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IntersectionCol("Intersection col",color) = (1,0,0,1)
        _IntersectWidth("_IntersectWith",range(0,1)) = 0.1

    }
    SubShader
    {

        //Tags{"RenderType"="Opquate"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"



            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float eyez : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                COMPUTE_EYEDEPTH(o.eyez);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _IntersectionCol;
            float _IntersectWidth;

            fixed4 frag (v2f i) : SV_Target
            {
                //Z buffer to linear depth
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.screenPos.xy/i.screenPos.w));

                fixed4 col = tex2D(_MainTex, i.uv);
                float halfWidth = _IntersectWidth / 2;
                //  深度值相差 在一定范围内，则是相交
                float depthDiff = saturate(abs(i.eyez - depth)/halfWidth);
                fixed4 finalCol = lerp(_IntersectionCol,col,depthDiff);
                return fixed4(finalCol.rgb,1);
            }
            ENDCG

                // half depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.proj)).r);
                // half deltaDepth = depth - i.proj.z;

                // // sample the textureUNITY_PROJ_COORD()i.proj
                // fixed4 col = lerp(_WaterColor01,_WaterColor02,min(_DepthRange,deltaDepth)/_DepthRange); //tex2D(_MainTex, i.uv);
                // col.a = min(_TranAmount,deltaDepth)/_TranAmount;// col.a * _TranAmount;
        }
    }
}
