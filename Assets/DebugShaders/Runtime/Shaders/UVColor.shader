Shader "Debug/UVColor"
{
    Properties
    {
        [Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)]
        _UVIndex ("UV Index", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            
            uint _UVIndex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                if(_UVIndex == 0) o.uv = v.uv0;
                else if(_UVIndex == 1) o.uv = v.uv1;
                else if(_UVIndex == 2) o.uv = v.uv2;
                else if(_UVIndex == 3) o.uv = v.uv3;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.uv, 0, 1);                
                return col;
            }
            ENDCG
        }
    }
}
