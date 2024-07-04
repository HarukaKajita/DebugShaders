Shader "Debug/VertexColor"
{
    Properties
    {
        [ToggleUI]_R("_R", int) = 1   
        [ToggleUI]_G("_G", int) = 1   
        [ToggleUI]_B("_B", int) = 1   
        [ToggleUI]_A("_A", int) = 1   
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
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
            };
            
            uint _R, _G, _B, _A;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                if (_R == 0) o.color.r = 0;
                if (_G == 0) o.color.g = 0;
                if (_B == 0) o.color.b = 0;
                if (_A == 0) o.color.a = 0;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;
                return col;
            }
            ENDCG
        }
    }
}
