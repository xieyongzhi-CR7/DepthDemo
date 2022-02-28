// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Easy_Soft"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5853087
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.2
		_EdgeIntensity("EdgeIntensity", Range( 0 , 2)) = 1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_Spread("Spread", Range( 0 , 1)) = 0.3388629
		_Softness("Softness", Range( 0 , 0.5)) = 0.199645
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 
		//#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 		
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _Softness;
		uniform float _EdgeWidth;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float temp_output_22_0 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (_ChangeAmount - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float clampResult14 = clamp( ( 1.0 - ( distance( temp_output_22_0 , _Softness ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( _EdgeColor * tex2DNode1 * _EdgeIntensity ) , clampResult14);
			o.Emission = lerpResult16.rgb;
			float smoothstepResult26 = smoothstep( _Softness , 0.5 , temp_output_22_0);
			o.Alpha = ( tex2DNode1.a * smoothstepResult26 );
		}

		ENDCG
		
	}
	Fallback "Diffuse"
}