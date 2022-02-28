Shader "custom/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_SourceTex("SourceTex",2D) = "white"{}
        //_Threshold("_Threshold",float) = 1
        //_Filter("_Filter",Vector) = (0,0,0,0)
    }

	CGINCLUDE
            #include "UnityCG.cginc"
            float _Threshold;
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
            float4 _MainTex_TexelSize;
            sampler2D _SourceTex;
            float4 _SourceTex_ST; 
            vector _Filter;  
			float _Intensity;
            half3 Sample(float2 uv)
            {
                return tex2D(_MainTex,uv).rgb;
            }
            //
            half3 SampleBox(float2 uv,float detail)
            {
                float4 o = _MainTex_TexelSize.xyxy * float4(-detail,-detail,detail,detail);
                half3 c = Sample(uv+ o.xy) + Sample(uv + o.xz) + Sample(uv+o.zw) +Sample(uv+o.zx);
                return c*0.25;
            }

            // half3 Prefilter(half3 c)
            // {
            //     half brightness = max(c.r,max(c.g,c.b));
            //     half contribution = max(0,brightness - _Threshold);
            //     contribution /= max(brightness,0.00001);
            //     return contribution*c;
            // }
            // 像素预过滤，能在cpu计算的，都放在cpu去计算，减少在gpu的计算
            half3 Prefilter(half3 c)
            {
                half brightness = max(c.r,max(c.g,c.b));
                half soft = brightness - _Filter.y;
                soft = clamp(soft,0,_Filter.z);
                soft = soft * soft/_Filter.w;
                half contribution = max(soft,brightness- _Filter.x);
                contribution /= max(brightness,0.00001);
                return contribution*c;
            }

	ENDCG
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Pass
        {        //像素的预筛选
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag        
            fixed4 frag (v2f i) : SV_Target
            {
                half3 col = Prefilter(SampleBox(i.uv,1));
                return fixed4(col,1);
            }
            ENDCG
        }

        Pass
        {
            //下采样
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag          

            fixed4 frag (v2f i) : SV_Target
            {
                
                half3 col = SampleBox(i.uv,1);
                return fixed4(col,1);
            }
            ENDCG
        }
        Pass
        {
            Blend One One
            // 上采样
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag          

            fixed4 frag (v2f i) : SV_Target
            {
                
                half3 col = SampleBox(i.uv,0.5);
                return fixed4(col,1);
            }
            ENDCG
        }
        Pass
        {
            //混合
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag  
            
                 

            fixed4 frag (v2f i) : SV_Target
            {
                
                half3 col = SampleBox(i.uv,0.5) + tex2D(_SourceTex,i.uv).rgb * _Intensity;
                //half3 col = SampleBox(i.uv,1);
                return fixed4(col,1);
            }
            ENDCG
        }
    }
}
