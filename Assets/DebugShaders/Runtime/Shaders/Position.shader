Shader "Debug/Position"
{
    Properties
    {
        [ToggleUI] _RepeatFraction ("Fraction", int) = 1
    }
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
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };
            uint _RepeatFraction;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 c = i.color;
                if(_RepeatFraction == 1)
                    c = frac(c);
                return c;
            }
            ENDCG
        }
    }
}
