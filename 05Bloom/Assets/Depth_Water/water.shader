Shader "custom/water"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _StrongWaterCol("strong water col",color)=(1,0,0,1)
        _LightWaterCol("light water col",color)=(1,1,1,1)
        _DepthRange("water depth range",Range(1,100)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 scrProj : TEXCOORD2;
                float eyeZ : TEXCOORD3;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float _DepthRange;
            float4 _LightWaterCol;
            float4 _StrongWaterCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.scrProj = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.eyeZ); // COMPUTE_EYEDEPTH
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.scrProj));
                //float resultDepth = depth - i.eyeZ;
                float resultDepth = depth - i.scrProj.z;
                float colparam = min(_DepthRange,resultDepth)/_DepthRange;
                // sample the texture
                float4 waterCol =  lerp(_LightWaterCol,_StrongWaterCol,colparam);
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(waterCol.rgb,0.5);
            }
            ENDCG
        }
    }
}
