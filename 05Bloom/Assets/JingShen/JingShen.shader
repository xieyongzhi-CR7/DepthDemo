Shader "Hidden/JingShen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
     #include "UnityCG.cginc"

            float _Threshold;
            // 焦点的距离
            float _FocalDistance;
            //近景模糊
            float _nearBlurScale;
            // 远景模糊
            float _farBlurScale;
            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 scrProj : TEXCOORD1;


            };
            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _SourceTex;
            float4 _SourceTex_ST; 
            vector _Filter;  
			float _Intensity;
            // 像素的预过滤
            // half3 Profile(float4 c)
            // {
            //     float brightness = max(c.r,max(c.g,c,b));
            //     half contribution = max(0,brightness - _Threshold);
            //     contribution /= max(brightness,0.000001);
            //     return c * contribution;
            // }
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
            // 采样图
            half3 sampleTex(float2 uv)
            {
                return tex2D(_MainTex,uv).rgb;
            }

            //权重分布
            half3 BoxSample(float2 uv,float detail)
            {
                float4 o = _MainTex_TexelSize.xyxy * float4(detail,detail,-detail,-detail);
                float3 col =0.25 *(sampleTex(uv+o.xy) + sampleTex(uv+o.xz) +sampleTex(uv+o.zx) +sampleTex(uv+o.zw));
                return col;
            }

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o; 
            }




    ENDCG
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            //像素的预过滤
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = Prefilter(BoxSample(i.uv,1));
                return fixed4(col,1);
            }
            ENDCG
        }
        Pass
        {
            // 向下采样
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = BoxSample(i.uv,1);
                return fixed4(col,1);
            }
            ENDCG
        }
        Pass
        {
            Blend One One
            // 向上采样
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = BoxSample(i.uv,0.5);
                return fixed4(col,1);
            }
            ENDCG
        }
        // Pass
        // {
        //     // 混合
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         float3 col = sampleTex(uv) + tex2D(_SourceTex,uv).rgb;
        //         return fixed4(col,1);
        //     }
        //     ENDCG
        // }
        Pass
        {
            // 景深的模糊混合
            Blend SrcAlpha OneMinusSrcAlpha
            // 混合
            CGPROGRAM            
            #pragma vertex vert_JingShen
            #pragma fragment frag
            v2f vert_JingShen(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrProj = ComputeScreenPos(o.pos);
                o.uv = v.uv;
                return o;
            }
                    // float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);  
        // //将深度值转化到01线性空间  
        // depth = Linear01Depth(depth);  
          
        // //如果depth小于焦点的物体，那么使用原始清晰图像，否则使用模糊的图像与清晰图像的差值，通过差值避免模糊和清晰之间明显的边界，结果为远景模糊效果  
        // fixed4 final = (depth <= _focalDistance) ? ori : lerp(ori, blur, clamp((depth - _focalDistance) * _farBlurScale, 0, 1));  
        // //上面的结果，再进行一次计算，如果depth大于焦点的物体，使用上面的结果和模糊图像差值，得到近景模糊效果  
        // final = (depth > _focalDistance) ? final : lerp(ori, blur, clamp((_focalDistance - depth) * _nearBlurScale, 0, 1));  
            
            fixed4 frag (v2f i) : SV_Target
            {
                float d = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrProj.xy/i.scrProj.w));
                float3 orgCol = tex2D(_SourceTex,i.uv).rgb;
                float3 blurCol = BoxSample(i.uv,0.5);
                // 远景的模糊
                float3 finalCol = (d <= _FocalDistance) ? orgCol : lerp(orgCol,blurCol,clamp((d - _FocalDistance) *_farBlurScale ,0,1));
                // 近景的模糊
                finalCol = (d < _FocalDistance) ? lerp(orgCol,blurCol,clamp((d-_FocalDistance)* _nearBlurScale,0,1)) : finalCol;
                
                return fixed4(finalCol,1);
            }
            ENDCG
        }
    }
}
