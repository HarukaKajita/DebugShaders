Shader "Debug/Normal"
{
    Properties
    {
        [Enum(NormalOS,0 , NormalWS, 1, TANGENTOS, 2, TANGENTWS, 3)]
        _OutputVector("Output Vector", int) = 0
        
        [ToggleUI]
        _Remap0to1("Remap 0 to 1", int) = 0
        
        [Enum(Raw,0 , CompresTo16bit, 1, CompresTo24bit, 2, CompresTo32bit, 3)]
        _CompressionType("Compression Type", int) = 0
        
        [Enum(RawVec,0 , Half Lambert, 1, CompressionDiff, 2)]
        _OutputConversion("Output Conversion", int) = 0
        
        _OutputIntensity ("Output Intensity", Range(0, 100)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
            #include "UnityCG.cginc"
            #include "VectorCompression.cginc"

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
            #define OUTPUT_CONVERSION_RAWVEC 0
            #define OUTPUT_CONVERSION_HALFLAMBERT 1
            #define OUTPUT_CONVERSION_COMPRESSIONDIFF 2
            uint _OutputConversion;

            float _OutputIntensity;
            
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

                const float3 rawVec = outputVector;
                
                if(_CompressionType == COMPRESSION_To16bit)
                {
                    const min16uint encoded = EncodeUnitVectorTo16bit(outputVector);
                    outputVector = DecodeUnitVectorFrom16bit(encoded);
                }
                else if(_CompressionType == COMPRESSION_To24bit)
                {
                    const uint encoded = EncodeUnitVectorTo24bit(outputVector);
                    outputVector = DecodeUnitVectorFrom24bit(encoded);
                }
                else if(_CompressionType == COMPRESSION_To32bit)
                {
                    const uint encoded = EncodeUnitVectorTo32bit(outputVector);
                    outputVector = DecodeUnitVectorFrom32bit(encoded);
                }

                if(_OutputConversion == OUTPUT_CONVERSION_HALFLAMBERT)
                {
                    outputVector = dot(lDir, outputVector)*0.5+0.5;
                }
                else if(_OutputConversion == OUTPUT_CONVERSION_COMPRESSIONDIFF)
                {
                    const float3 compressed = outputVector;
                    outputVector = abs(compressed - rawVec);
                }
                    
                
                return float4(outputVector*_OutputIntensity,1);
            }
            ENDCG
        }
    }
}
