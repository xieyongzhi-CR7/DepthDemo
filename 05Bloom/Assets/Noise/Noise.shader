Shader "custom/Noise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogYSpeed("_FogYSpeed",float) = 1
        _FogXSpeed("_FogXSpeed",float) = 1

    }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always

        Pass
        {
            Tags
            {
                "RenderType"="Opaque"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //
            // struct appdata
            // {
            //     float4 vertex : POSITION;
            //     float2 uv : TEXCOORD0;
            // };
            //
            //
            // struct v2f
            // {
            //     float2 uv : TEXCOORD0;
            //     float4 vertex : SV_POSITION;
            //     float4 scrProj : TEXCOORD1;
            //     float2 uv_depth : TEXCOORD2;
            //     float4 interpolatedRay : TEXCOORD3;
            // };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _FrustumCornersRay;

            float4 _FogColor;
            float _FogDensity;
            float _FogStart;
            float _FogEnd;

            float whiteNoise(int seed, int i, int j)
            {
                //return  frac(sin(dot(float2(i,cos(j)),float2(seed+12.9898,seed + 78.233)))*43758.5453);
                float r = frac(
                    sin(dot(float2(i, cos(j)), float2(float(seed) + 12.9898, float(seed) + 78.233))) * 43758.5453);
                return r;
            }

            float HashGrid(int seed, int i, int j)
            {
                // 将得到的白噪声的值（0，1） -》还原为 （-1，-1） 
                float r = whiteNoise(seed, i, j);
                r = r * 2.0f - 1.0f;
                return r;
            }

            float2 ComputeGradient(int seed, int gridX, int gridY)
            {
                float2 gradient = float2(HashGrid(seed * 123 + 345, gridX, gridY),
                                         HashGrid(seed * 456 + 234, gridX, gridY));
                //float2 gradient = float2(HashGrid(seed * 123 + 456, gridX, gridY),
                //HashGrid(seed * 456 + 123, gridX, gridY));
                return gradient;
            }

            // smooth interpolation for perlin noise
            float SmoothLerp(float min, float max, float t)
            {
                t = t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
                return min + t * (max - min);
            }

      
            float smoothstep(float a, float b, float x)
            {
                float t = saturate((x - a) / (b - a));
                return t * t * (3.0 - (2.0 * t));
            }

            float perlinNoise(int seed, float2 p, float gridSize)
            {
                p /= gridSize;
                int gridX = floor(p.x); // / gridSize);
                int gridY = floor(p.y); // / gridSize);
                float2 gradient00 = ComputeGradient(seed, gridX, gridY);
                float2 gradient01 = ComputeGradient(seed, gridX, gridY + 1);
                float2 gradient10 = ComputeGradient(seed, gridX + 1, gridY);
                float2 gradient11 = ComputeGradient(seed, gridX + 1, gridY + 1);

                float2 v00 = float2(gridX, gridY); // * gridSize;
                float2 v01 = float2(gridX, gridY + 1); // * gridSize;
                float2 v10 = float2(gridX + 1, gridY); // * gridSize;
                float2 v11 = float2(gridX + 1, gridY + 1); // * gridSize;

                float dp00 = dot((p - v00), gradient00);
                float dp01 = dot((p - v01), gradient01);
                float dp10 = dot((p - v10), gradient10);
                float dp11 = dot((p - v11), gradient11);

                // bilinear interpolation
                float tx = (p.x - v00.x); // / gridSize;
                float ty = (p.y - v00.y); // / gridSize;
                //float res = SmoothLerp(SmoothLerp(dp00, dp10, tx), SmoothLerp(dp01, dp11, tx), ty);
                // float res = lerp(lerp(dp00, dp10, tx), lerp(dp01, dp11, tx), ty);
                float res = SmoothLerp(SmoothLerp(dp00, dp10, tx), SmoothLerp(dp01, dp11, tx), ty);
                //float res = lerp(lerp(dp00, dp10, tx), lerp(dp01, dp11, tx), ty);
                return res;
            }

            // 分形布朗运动
            float perLinNoiseFBM(int seed, float2 p, float gridSize)
            {
                float2x2 mat = {
                    0.8f, 0.6f,
                    -0.6f, 0.8f
                };
                float f = 0.0f;
                int numFbmSteps = 6;
                float multiplier[6] = {2.02f, 2.03f, 2.01f, 2.04f, 2.01f, 2.02f};
                float amp = 1.0f;
                for (int i = 0; i < numFbmSteps; i++)
                {
                    f += amp * perlinNoise(seed, p, gridSize);
                    p = mul(mat, p) * multiplier[i];
                    amp *= 0.5f;
                }
                return f / 0.96875f;
            }

            // v2f vert(appdata v)
            // {
            //     v2f o;
            //     o.vertex = UnityObjectToClipPos(v.vertex);
            //     o.uv = v.uv;
            //     o.uv_depth = v.uv;
            //     # if UNITY_UV_STARTS_AT_TOP
            //     o.uv_depth.y = 1 - o.uv_depth.y;
            //     #endif
            //     int index = 0;
            //     float2 uv = v.uv;
            //     if (uv.x < 0.5 && uv.y < 0.5)
            //     {
            //         index = 0;
            //     }
            //     else if (uv.x > 0.5 && uv.y < 0.5)
            //     {
            //         index = 1;
            //     }
            //     else if (uv.x > 0.5 && uv.y > 0.5)
            //     {
            //         index = 2;
            //     }
            //     else if (uv.x < 0.5 && uv.y > 0.5)
            //     {
            //         index = 3;
            //     }
            //     #if UNITY_UV_STARTS_AT_TOP
            //     if (_MainTex_TexelSize.y < 0)
            //         index = 3 - index;
            //     #endif
            //     o.interpolatedRay = _FrustumCornersRay[index];
            //     return o;
            // }


            #include "UnityCG.cginc"
            //#include "../Common/PerlinWorleyNoiseGenerator.cginc"

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
            float _FogYSpeed;
            float _FogXSpeed;

            //sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
                // float3 worldPos = _WorldSpaceCameraPos + depth * i.interpolatedRay.xyz;
                // // y值越小， 浓度越高
                // float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
                //
                //
                // fogDensity = saturate(fogDensity * _FogDensity);
                //
                // fixed4 finalCol = tex2D(_MainTex,i.uv);
                // finalCol.rbg = lerp(finalCol.rgb,_FogColor.rgb,fogDensity);
                float gridSize = 0.5f;
                //float3 finalCol = perLinNoiseFBM(421, i.uv, gridSize);
                float2 speed = _Time.y * float2(_FogXSpeed,_FogYSpeed);
                float3 finalCol = perlinNoise(42, i.uv + speed, gridSize);
                return fixed4(finalCol,1);
            }
            ENDCG
        }
    }
}