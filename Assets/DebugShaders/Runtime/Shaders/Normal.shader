Shader "Debug/Normal"
{
    Properties
    {
        [Enum(NormalOS,0 , NormalWS, 1, TANGENTOS, 2, TANGENTWS, 3)]
        _OutputVector("Output Vector", int) = 0
        
        [ToggleUI]
        _Remap0to1("Remap 0 to 1", int) = 0
        
        [ToggleUI]
        _CompressTo16bit("Compress to 16 bit", int) = 0
        
        [ToggleUI]
        _OutputHalfLambert("Output Half Lambert", int) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 positionWS : POSITIONWS;
                float3 normalOS : NORMALOS;
                float3 normalWS : NORMALWS;
                float3 tangentOS : TANGENTOS;
                float3 tangentWS : TANGENTWS;
            };

            #define OUTPUT_NORMALOS 0
            #define OUTPUT_NORMALWS 1
            #define OUTPUT_TANGENTOS 2
            #define OUTPUT_TANGENTWS 3
            uint _OutputVector;
            uint _Remap0to1;
            uint _CompressTo16bit;
            uint _OutputHalfLambert;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normalOS = normalize(v.normal);
                o.normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.tangentOS = normalize(v.tangent.xyz);
                o.tangentWS = normalize(UnityObjectToWorldNormal(v.tangent.xyz));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 CartesianToSpherical(float3 cartesian)
            {
               //work for vector -z
               float theta = atan2(cartesian.z, cartesian.x); 
               //float theta = (float)Math.Atan(cartesian.z /cartesian.x);

               float phi = acos(cartesian.y);
               return float2(theta, phi);
            }
            float3 DecodeUnitVector16(min16uint encode)
            {
                uint n = encode & 0x1FFF;
                uint i = (sqrt(1 + 8 * n) - 1) / 2;
                uint j = n - (i + 1) * i / 2;
                
                float phi = i * 1.5707963267 / 126;
                float theta = i > 0 ? j * 1.5707963267 / i : 0;

                float3 normal = float3(cos(theta) * sin(phi),cos(phi),sin(theta) * sin(phi));
                
                if ((encode & 0x8000) != 0) normal.x *= -1;
                if ((encode & 0x4000) != 0) normal.y *= -1;
                if ((encode & 0x2000) != 0) normal.z *= -1;
                
                return normal;
            }
            fixed4 frag (v2f input) : SV_Target
            {
                const float3 positionWS = input.positionWS;
                const float3 lDir = normalize(UnityWorldSpaceLightDir(positionWS));
                
                float3 outputVector = 0;
                if(_OutputVector == OUTPUT_NORMALOS)
                    outputVector = normalize(input.normalOS);
                else if(_OutputVector == OUTPUT_NORMALWS)
                    outputVector = normalize(input.normalWS);
                else if(_OutputVector == OUTPUT_TANGENTOS)
                    outputVector = normalize(input.tangentOS);
                else if(_OutputVector == OUTPUT_TANGENTWS)
                    outputVector = normalize(input.tangentWS);

                if(_Remap0to1 == 1)
                    outputVector = outputVector*0.5 + 0.5;

                min16uint compressedValue = 0;
                if(_CompressTo16bit == 1)
                {
                    const uint resolution = 126;
                    const float delta_phi = (UNITY_PI/2.0)/resolution;
                    const float delta_theta = delta_phi;
                    float3 vec = outputVector;
                    // 先頭3bitに符号を格納
                    if (vec.x < 0) { compressedValue |= 1 << 15; vec.x *= -1; }
                    if (vec.y < 0) { compressedValue |= 1 << 14; vec.y *= -1; }
                    if (vec.z < 0) { compressedValue |= 1 << 13; vec.z *= -1; }
                    // ベクトルの向きを立体角に変換
                    const float2 thetaPhi = CartesianToSpherical(vec);
                    // 立体角を解像度で量子化
                    const uint i = round(thetaPhi.y / delta_phi);
                    const uint j = round(thetaPhi.x * i * 2 / UNITY_PI);

                    const uint n = (i+1)*i/2 + j;
                    compressedValue |= (uint)n;
                    outputVector = DecodeUnitVector16(compressedValue);
                }

                if(_OutputHalfLambert == 1)
                {
                    outputVector = dot(lDir, outputVector)*0.5+0.5;
                }
                    
                
                return float4(outputVector,1);
            }
            ENDCG
        }
    }
}
