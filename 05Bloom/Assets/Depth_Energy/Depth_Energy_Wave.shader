Shader "Unlit/Depth_Energy_Wave"
{
    Properties
    {
    
        _CircleR("CIrlceR",range(0,0.5)) = 0.2
    _RingWidth("RingWidth",range(0,1)) = 1
        _MainColor ("Texture", color) = (1,0,0,1)
        //_IntersectionCol("intersection col",color) = (1,0,0,1)
        //_EdgeWidth("edge width",range(0,10)) = 1
        _RimPower("_RimPower",range(0,1)) = 1
        _IntersectionPower(" intersection power",range(0,0.5))= 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        GrabPass{
        "_GrabTexture"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 scrProj:TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float eyeZ : TEXCOORD3;
                float3 worldNormal : TEXCOORD4;
            };

            float4 _MainColor;
            sampler2D _CameraDepthTexture;
            float _RimPower;
            float _IntersectionPower;
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            
        //--------------------------------
        
        float _CircleR;
        float _RingWidth;
            float circle(float2 uv,float r,float InTime){
                float dis = distance(uv,float2(0.5,0.5));
                float circle1 =   step(dis,r + 0.1);
                float circle2 = step(r - 0.1,dis);
                float circle = circle2 * circle1;
                circle *= 1 - abs(dis - InTime) / 0.2;
                return circle;               
            }
        
        //--------------------------------    
            
            
            
            
              
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                COMPUTE_EYEDEPTH(o.eyeZ);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.scrProj = ComputeScreenPos(v.vertex);
                o.worldNormal = UnityObjectToWorldDir(v.normal);
                return o;
            }
            
            
            
            
            fixed4 frag (v2f i) : SV_Target
            {            
            fixed4 c = 1; 
            fixed dis = distance (i.uv , fixed2(0.5,0.5));
            fixed mask = step ((_CircleR - _RingWidth) , dis) * step (dis , (_RingWidth + _CircleR));
            mask *= 1 - abs(dis - _CircleR) / _RingWidth;				
            c = tex2Dproj (_GrabTexture , (i.scrProj + mask * _GrabTexture_TexelSize));
            return float4(mask.xxx,1);
            
            
            
            
            //------------------
              float r = circle(i.uv,_CircleR,_RingWidth);
              //float4 screenCol = tex2Dproj(_GrabTexture,i.scrProj + r * _GrabTexture_TexelSize );
              float4 screenCol = tex2Dproj(_GrabTexture,i.scrProj);
              //float4 screenCol = tex2Dproj(_GrabTexture,float4( float2(i.scrProj.xy + r * _GrabTexture_TexelSize.xy),i.scrProj.zw ));
                    //return float4(r.xxx,1);
                    return float4(screenCol);
            //------------------
            
            
                float3 worldPos = i.worldPos;
                float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldLight =normalize(UnityWorldSpaceLightDir(worldPos));
                float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrProj.xy/i.scrProj.w));

                float rim = 1 - saturate(dot(i.worldNormal,worldView)) * _RimPower;

                float intersect = (1 - (screenZ - i.eyeZ)) * _IntersectionPower;
                float v = max(rim,intersect);
                //return _MainColor * v  + screenCol;
            }
            ENDCG
        }
    }
}
