Shader "custom/fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogXSpeed("_fogXSpeed",range(0,0.5)) = 0.01
        _FogYSpeed("_fogYSpeed",range(0,0.5)) = 0.03
    }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always

        Pass
        {
            Tags { "RenderType"="Opaque" }
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
                float4 scrProj : TEXCOORD1;
                float2 uv_depth : TEXCOORD2;
                float4 interpolatedRay : TEXCOORD3;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _FrustumCornersRay;

            float4 _FogColor;
            float _FogDensity;
            float _FogStart;
            float _FogEnd;
            float _FogXSpeed;
            float _FogYSpeed;

            float whiteNoise(int seed, int i, int j)
            {
                //return  frac(sin(dot(float2(i,cos(j)),float2(seed+12.9898,seed + 78.233)))*43758.5453);
                return frac(
                    sin(dot(float2(i, cos(j)), float2(float(seed) + 12.9898, float(seed) + 78.233))) * 43758.5453);
            }

            float HashGrid(int seed, int i, int j)
            {
                // 将得到的白噪声的值（0，1） -》还原为 （-1，-1） 
                float r = whiteNoise(seed, i, j);
                r = r * 2 - 1;
                return r;
            }

            float2 ComputeGradient(int seed, int gridX, int gridY)
            {
                float2 gradient = float2(HashGrid(seed * 123 + 456, gridX, gridY),
                                         HashGrid(seed * 456 + 123, gridX, gridY));
                return gradient;
            }

            float perlinNoise(int seed, float2 p, float gridSize)
            {
                p /= gridSize;
                int gridX = floor(p.x);
                int gridY = floor(p.y);
                float2 gradient00 = ComputeGradient(seed, gridX, gridY);
                float2 gradient01 = ComputeGradient(seed, gridX, gridY + 1);
                float2 gradient10 = ComputeGradient(seed, gridX + 1, gridY);
                float2 gradient11 = ComputeGradient(seed, gridX + 1, gridY + 1);

                float2 v00 = float2(gridX, gridY);
                float2 v01 = float2(gridX, gridY + 1);
                float2 v10 = float2(gridX + 1, gridY);
                float2 v11 = float2(gridX + 1, gridY + 1);
                float dp00 = dot((p - v00), gradient00);
                float dp01 = dot((p - v01), gradient01);
                float dp10 = dot((p - v10), gradient10);
                float dp11 = dot((p - v11), gradient11);
                // blinear interpolation
                float tx = (p.x - v00.x);
                float ty = (p.y - v00.y);
                float res = lerp(lerp(dp00, dp10, tx), lerp(dp01, dp11, tx), ty);
                return res;
            }

            float PerlinNoiseFBM6(int seed, float2 p, float gridSize)
            {
                // const float aspect = 2.0f;
                // p.x *= aspect;
                // fBM : https://www.iquilezles.org/www/articles/fbm/fbm.htm
                // https://www.shadertoy.com/view/lsl3RH
                // https://www.shadertoy.com/view/XslGRr
                //Vector4 deltaVec = new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), 0.0f, 0.0f); ;// new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), 0.0f, 0.0f);
                float2x2 mat = {
                    //some rotation matrix
                    0.8f, 0.6f,
                    -0.6f, 0.8f
                };
                float f = 0.0f;
                int numFbmSteps = 6;
                float multiplier[6] = {2.02f, 2.03f, 2.01f, 2.04f, 2.01f, 2.02f};
                // float multiplier[6] = { 1.02f, 2.03f, 3.01f, 2.04f, 3.01f, 3.02f };
                float amp = 1.0f;
                for (int i = 0; i < numFbmSteps; ++i)
                {
                    f += amp * perlinNoise(seed, p, gridSize);
                    p = mul(mat, p) * multiplier[i];
                    //(2.0f + Random.Range(0.0f, 0.05f));//brownian motion applied to sample coord
                    // p *= multiplier[i];
                    amp *= 0.5f;
                }
                return f / 0.96875f;
            }
            // 分形布朗运动
            float perLinNoiseFBM(int seed,float2 p,float gridSize)
            {
                float2x2 mat = {
                    0.8f,0.6f,
                    -0.6f,0.8f
                };
                float f = 0.0f;
                int numFbmSteps = 6;
                float multiplier[6] = {2.02f,2.03f,2.01f,2.04f,2.01f,2.02f};
                float amp = 1.0f;
                for (int i = 0;i<numFbmSteps;i++)
                {
                    f += amp * perlinNoise(seed,p,gridSize);
                    p = mul(mat,p) * multiplier[i];
                    amp *= 0.5f;
                }
                return  f / 0.96875f;
            }            

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv_depth = v.uv;
                # if UNITY_UV_STARTS_AT_TOP
                o.uv_depth.y = 1 - o.uv_depth.y;
                #endif
                int index = 0;
                float2 uv = v.uv;
                if (uv.x < 0.5 && uv.y < 0.5)
                {
                    index = 0;
                }
                else if (uv.x > 0.5 && uv.y < 0.5)
                {
                    index = 1;
                }
                else if (uv.x > 0.5 && uv.y > 0.5)
                {
                    index = 2;
                }
                else if (uv.x < 0.5 && uv.y > 0.5)
                {
                    index = 3;
                }
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    index = 3 - index;
                #endif
                o.interpolatedRay = _FrustumCornersRay[index];
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                
                float speed = _Time.y * float2(_FogXSpeed,_FogYSpeed);
                float gridSize = 0.500;
                float nosie = perLinNoiseFBM(42, i.uv + speed, gridSize);
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
                // interpolatedRay 是在世界空间中的 带有方向的向量
                // transform.forward  是相对于世界坐标的方向
                // 一个 A点，沿着另一个方向  平移一个确定的大小，就是A点平移后的位置
                float3 worldPos = _WorldSpaceCameraPos + depth * i.interpolatedRay.xyz;
                 // y值越小， 浓度越高
                float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
                fogDensity = saturate(fogDensity * _FogDensity * (1+ nosie));
                //
                fixed4 finalCol = tex2D(_MainTex,i.uv);
                finalCol.rbg = lerp(finalCol.rgb,_FogColor.rgb,fogDensity);
                return fixed4(finalCol);
            }
            ENDCG
        }
    }
}