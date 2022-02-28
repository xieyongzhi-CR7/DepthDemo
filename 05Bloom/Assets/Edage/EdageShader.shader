Shader "Custom/EdageShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor(" edge color",color)=(1,1,1,1)
        _BackgroundColor("Bg color",color) = (1,1,1,1)
        _EdgeOnly("Edge only",float) = 1
    }
    CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float4 _BackgroundColor;
        float4 _EdgeColor;
        float  _EdgeOnly;

        struct a2v
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv[9] : TEXCOORD0;
        };

        //求出灰度值
        fixed luminance(fixed4 color)
        {
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        const half Gx[9]={
            -1,-2,-1,
            0,0,0,            
            1,2,1
            };

        const half Gy[9]={
            -1,0,1,
            -2,0,2,            
            -1,0,1
            };
        half sobel(float2 uv[9])
        {
                half edageColorX= 0;
                half edageColory= 0;
                for (int i=0;i<9;i++)
                {
                    half gray = luminance(tex2D(_MainTex,uv[i]));
                    edageColorX += gray * Gx[i];
                    edageColory +=gray * Gy[i];                   
                }
                return abs(edageColorX) + abs(edageColory);
        }
        v2f vert(a2v v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            float2 uv = v.uv;
            o.uv[0] = uv;
            o.uv[1] = uv + _MainTex_TexelSize.xy * float2(0,1);
            o.uv[2] = uv + _MainTex_TexelSize.xy * float2(-1,1);
            o.uv[3] = uv + _MainTex_TexelSize.xy * float2(1,1);
            o.uv[4] = uv + _MainTex_TexelSize.xy * float2(-1,0);
            o.uv[5] = uv + _MainTex_TexelSize.xy * float2(1,0);
            o.uv[6] = uv + _MainTex_TexelSize.xy * float2(0,-1);
            o.uv[7] = uv + _MainTex_TexelSize.xy * float2(-1,-1);
            o.uv[8] = uv + _MainTex_TexelSize.xy * float2(1,-1);
            return o;
        }
    ENDCG



// 第一 边缘检测
// 第二 横向检测
// 第三 纵向检测
// 输出
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                half gra = sobel(i.uv);
                fixed4 withEdgeColor = lerp(tex2D(_MainTex,i.uv[0]),_EdgeColor,gra);
                fixed4 onlyEdgeColr = lerp(_BackgroundColor,_EdgeColor,gra);
                return lerp(withEdgeColor,onlyEdgeColr,_EdgeOnly);
            }
            ENDCG
        }
    }
}
