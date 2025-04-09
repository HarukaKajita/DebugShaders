Shader "Unlit/BoneIndexWeight"
{
    Properties {}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 blendWeight : BLENDWEIGHTS;
                uint4 blendIndex : BLENDINDICES;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                uint4 blendIndex : BLENDINDICES;
                float4 blendWeight : BLENDWEIGHTS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.blendIndex = v.blendIndex;
                o.blendWeight = v.blendWeight; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                uint index = i.blendIndex;
                fixed4 col = index/100.0;
                return col;
            }
            ENDCG
        }
    }
}
