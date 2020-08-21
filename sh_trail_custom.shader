Shader "BeatSaber/Fire Trail" 
{
Properties {
    _AlphaTex ("Alpha texture", 2D) = "white" {}
	_DisplaceTex ("Displace Texture", 2D) = "black" {}
	_MaskTex("Fade Mask", 2D) = "white" {}
	_DispPower("Displacement Intensity", Float) = 0.2
	_DispSpeed("Displacement Speed", Float) = -1
	_TexOffset("Displacement Offset", Vector) = (0,0,0,0)
	_Glow("Glow", Range(0,10)) = 0.75
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha OneMinusSrcAlpha
    ColorMask RGB
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _AlphaTex;
			sampler2D _DisplaceTex;
			sampler2D _MaskTex;
			float _DispPower;
			float _DispSpeed;
			float2 _TexOffset;
			fixed _Glow;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

			float4 _DisplaceTex_ST;
			float4 _AlphaTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 disp = i.uv + float2(tex2D(_DisplaceTex, TRANSFORM_TEX(i.uv + float2(0.0,_Time.y*_DispSpeed), _DisplaceTex)).x * 2.0, tex2D(_DisplaceTex, TRANSFORM_TEX(i.uv + float2(0.0,_Time.z*_DispSpeed), _DisplaceTex)).y) * _DispPower;

				fixed4 col = i.color;

                col.a = tex2D(_AlphaTex, TRANSFORM_TEX(disp, _AlphaTex) + _TexOffset).r * i.color.a * _Glow * tex2D(_MaskTex,i.uv);

                return col;
            }
            ENDCG
        }
    }
}
}
