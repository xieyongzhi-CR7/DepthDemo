Shader "Unlit/flowMap_code"
{
	Properties
	{
		_Noise ("_Noise", 2D) = "white" {}
		_FlowMap ("_FlowMap", 2D) = "white" {}
		_NoiseSpeed ("_NoiseSpeed", float) = 1
		_NoiseStrength ("_NoiseSpeed", vector) = (1,1,1,1)
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
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv_flow : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _Noise,_FlowMap;
			float4 _Noise_ST,_FlowMap_ST;
			float _NoiseSpeed;
			float4 _NoiseStrength;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Noise);
				o.uv_flow = TRANSFORM_TEX(v.uv, _FlowMap);
				return o;
			}
			
			// float2(abs(temp.x) - floor(abs(temp.x))
			
			fixed4 frag (v2f i) : SV_Target
			{			
			    float2 uv = i.uv;   
			    float4 flowCol = tex2D(_FlowMap,i.uv_flow);
			    flowCol.x = -flowCol.x + 0.5;
			    //float2 timeScale =  fract( _Time.x * _NoiseSpeed)  * _NoiseStrength;  
			    float2 timeScale =  float( _Time.x * _NoiseSpeed) - floor(_Time.x * _NoiseSpeed)  * _NoiseStrength;
			    float2  uvOffset =( flowCol.rg ) * timeScale;
			    uv = uv + uvOffset;
				float2 uv1 = i.uv;
				//float2 timeScale1 = fract( _Time.x * _NoiseSpeed + 0.5)  * _NoiseStrength;
				float2 timeScale1 = float( _Time.x * _NoiseSpeed + 0.5) - floor(_Time.x * _NoiseSpeed + 0.5)  * _NoiseStrength;
				float2 uvOffset1 =  flowCol.rg * timeScale1;
				
				uv1 = uv + uvOffset1;
				//float lerpFactor = abs(fract(_Time.x * _NoiseSpeed) * 2 - 1);			
				float lerpFactor = abs((float( _Time.x * _NoiseSpeed) - floor(_Time.x * _NoiseSpeed)) * 2 - 1);		
				fixed4 col = tex2D(_Noise, uv);
				fixed4 col1 = tex2D(_Noise, uv1);			
				float4 finalCol = lerp(col,col1,lerpFactor);
		
				return finalCol;
			}
			ENDCG
		}
	}
}
