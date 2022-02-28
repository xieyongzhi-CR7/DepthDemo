Shader "Unlit/SnowShader"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _BaceTex ("BaceTex", 2D) = "white" {}
	_SnowColor("SnowColor", Color) = (1,1,1,1)
		_SnowTex("SnowTex", 2D) = "white" {}

	_MaskTex("mask tex",2D) = "white"{}
	_aaaa("TesselationNum",Range(0.1,100)) = 0.145299

		_Displacement("_Displacement",Range(0.1,100)) = 0.5
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM

        #pragma hull hull
        #pragma domain domain

			#pragma vertex tessvert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
#include "Tessellation.cginc"
#pragma multi_compile_fwdbase_fullshadows
#pragma only_renderers d3d9 d3d11 glcore gles
#pragma target 5.0

		sampler2D _BaceTex,_SnowTex,_MaskTex;
	float4 _MaskTex_ST ;
	float _aaaa;
	float4 _Color, _SnowColor;
	float _Displacement;
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;

            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                
                float4 pos : SV_POSITION;
				float3 normal_dir : TEXCOORD1;
				float2 uv_bace : TEXCOORD2;
				float2 uv_snow : TEXCOORD3;
            };
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexInput)0;
				o.uv = v.uv;
				o.normal_dir = UnityObjectToWorldNormal(v.normal);

				float4 _MaskTex_var = tex2Dlod(_MaskTex, float4(o.uv, 0, 0));
				float4 _BaceTex_var = tex2Dlod(_BaceTex, float4(o.uv, 0, 0));

				v.vertex.xyz -= v.normal * (_BaceTex_var.r - 0.7 + _MaskTex_var.r) * _Displacement;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
			struct TessVertex {
				float4 vertex : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};
			struct OutputPatchConstant {
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
				float3 vTangent[4] : TANGENT;
				float2 vUV[4] : TEXCOORD;
				float3 vTanUCorner[4] : TANUCORNER;
				float3 vTanVCorner[4] : TANVCORNER;
				float3 vCWts :TANWELIGHTS;
			};
			//将顶点里的处理 传入到曲面细分中
			TessVertex tessvert(VertexInput v) {
				TessVertex o;
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.uv = v.uv;
				return o;
			}
			// 曲面细分的  远近控制（近处细分，远处不细分）
			float4 Tessellation(TessVertex v, TessVertex v1, TessVertex v2) {
				float minDist = 1.0;
				float maxDist = 25.0;
				return UnityDistanceBasedTess(v.vertex, v1.vertex, v2.vertex, minDist, maxDist, _aaaa);
			}
			// 曲面细分的强度控制
			float Tessellation(TessVertex v)
			{
				return _aaaa;
			}

			// 类似于 从顶点里 传入到片元里: 决定了如何对三角形进行细分
			OutputPatchConstant hullconst(InputPatch<TessVertex, 3> v) {
				OutputPatchConstant o = (OutputPatchConstant)0;
				float4 ts = Tessellation(v[0], v[1], v[2]);
				o.edge[0] = ts.x;
				o.edge[1] = ts.y;
				o.edge[2] = ts.z;
				o.inside = ts.w;
				return o;
			}

			
			[domain("tri")] // 定义特性  输入进hull shader的图元是三角形
			[partitioning("fractional_odd")]// 决定分割方式
			[outputtopology("triangle_cw")]//决定图元的朝向
			[patchconstantfunc("hullconst")]// 补丁常量缓存函数名
			[outputcontrolpoints(3)]//决定三个控制点
			TessVertex hull(InputPatch<TessVertex, 3> v, uint id : SV_OutputControlPointID) {
				return v[id];
			}

			[domain("tri")]
			VertexOutput domain(OutputPatchConstant tessFactors, const OutputPatch<TessVertex, 3> vi, float3 bary : SV_DomainLocation)
			{
				VertexInput v = (VertexInput)0;
				v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
				v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;

				v.tangent = vi[0].tangent * bary.x + vi[1].tangent * bary.y + vi[2].tangent * bary.z;
				v.uv = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;
				VertexOutput o = vert(v);
				return o;
			}
#endif

            fixed4 frag (VertexOutput i) : SV_Target
            {               
				float4 _MaskTex_var = tex2D(_MaskTex, TRANSFORM_TEX(i.uv,_MaskTex));
			float4 BaceTex_var = tex2D(_BaceTex, i.uv) * _Color;
			float4 SnowTex_var = tex2D(_SnowTex, i.uv) * _SnowColor;
                
			float4 c = lerp(BaceTex_var, SnowTex_var, _MaskTex_var.r);
				float3 finalColor = c.xyz;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}
