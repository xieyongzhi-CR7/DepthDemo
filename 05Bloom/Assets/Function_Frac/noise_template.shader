﻿Shader "Image/Shader14"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Fog Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float3 _Color;

			float rand(float2 p){
				return frac(sin(dot(p ,float2(12.9898,78.233))) * 43758.5453);
			}

			float noise(float2 x)
			{
				float2 i = floor(x);
				float2 f = frac(x);
				float a = rand(i);
				float b = rand(i + float2(1.0, 0.0));
				float c = rand(i + float2(0.0, 1.0));
				float d = rand(i + float2(1.0, 1.0));
				float2 u = f * f * f * (f * (f * 6 - 15) + 10);
				float x1 = lerp(a,b,u.x);
				float x2 = lerp(c,d,u.x);
				return lerp(x1,x2,u.y);
			}

			float fbm(float2 x)
			{
				float scale = 7;
				float res = 0;
				float w = 4;
				for(int i=0;i<4;++i)
				{
					res += noise(x * w);
					w *= 1.5;
				}
				return res;
			}
                            // float mask = 1.0f - pixel.uv.y; //vertical
                // mask -= abs(2.0f * (pixel.uv.x - 0.5f)); //horizontal
                // return fixed4(mask,mask,mask, 1.0f);

			fixed4 frag (v2f i) : SV_Target
			{
                //   水平方向
				float mask = 1.0 -i.uv.y;
                // 竖直方向
                mask -= abs(2.0 * (i.uv.x - 0.5));				
                return fixed4(mask,mask,mask,1);
			}
			ENDCG
		}
	}
}
