// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Easy"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.37
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.2
		_EdgeIntensity("EdgeIntensity", Range( 0 , 2)) = 1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
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
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float temp_output_4_0 = ( tex2D( _Gradient, uv_Gradient ).r - (-1.0 + (_ChangeAmount - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) );
			float clampResult14 = clamp( ( 1.0 - ( distance( temp_output_4_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( _EdgeColor * _EdgeIntensity ) , clampResult14);
			o.Emission = lerpResult16.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , temp_output_4_0 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
657;145;1183;830;437.9191;351.1394;1.273435;True;False
Node;AmplifyShaderEditor.RangedFloatNode;5;-389.5255,233.0212;Float;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;False;0;0.37;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-395.3999,5;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;False;0;-1;60804a2d67125e242947303c73c6facf;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;6;-129.5259,369.5211;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-52.32109,199.8836;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;103.0397,444.7571;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;0.5;0.5;0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;152.7034,558.093;Inherit;False;Property;_EdgeWidth;EdgeWidth;4;0;Create;True;0;0;False;0;0.2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;8;224.0158,325.0543;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;399.75,318.6871;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-9.022123,-27.68709;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;5;0;Create;True;0;0;False;0;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;595.8594,351.7965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;2.438976,-242.8979;Inherit;False;Property;_EdgeColor;EdgeColor;6;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;188.3603,-116.8275;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-337.2656,-312.7265;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;-1;b97f5eaa006aaa34aae366b1e70f8ea3;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;7;223.7538,210.1259;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;14;728.2966,477.8665;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;16;330.9851,-283.6474;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-30.345,47.11858;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;506.3122,-203.9063;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Easy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;5;0
WireConnection;4;0;2;1
WireConnection;4;1;6;0
WireConnection;8;0;4;0
WireConnection;8;1;10;0
WireConnection;11;0;8;0
WireConnection;11;1;12;0
WireConnection;13;0;11;0
WireConnection;17;0;15;0
WireConnection;17;1;18;0
WireConnection;7;1;4;0
WireConnection;14;0;13;0
WireConnection;16;0;1;0
WireConnection;16;1;17;0
WireConnection;16;2;14;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;0;2;16;0
WireConnection;0;10;3;0
ASEEND*/
//CHKSM=72F84FB3A3770EC3194DA2ED2466E59F8BE1353E