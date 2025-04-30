cbuffer LightBuffer : register(b0)
{
    float3 LightDirection;
    float3 LightColor;
    float LightIntensity;
    float Padding;
}

cbuffer MaterialBuffer : register(b1)
{
    float3 DiffuseColor;
    float TextureScale;
    float Shininess;
    float3 Padding2;
};

Texture2D DiffuseTexture : register(t0);
Texture2D NormalTexture : register(t1);
SamplerState LinearSampler : register(s0);
SamplerState PointSampler : register(s1);

struct PSInput
{
    float4 Position : SV_POSITION;
    float2 TexCoord : TEXCOORD0;
    float3 Normal : NORMAL;
    float3 WorldPos : TEXCOORD1;
};

// 像素着色器主函数
float4 main(PSInput input) : SV_TARGET
{
    float4 diffuseSample = DiffuseTexture.Sample(LinearSampler, input.TexCoord * TextureScale);

    float3 normalSample = NormalTexture.Sample(PointSampler, input.TexCoord * TextureScale).xyz;
    normalSample = normalSample * 2.0 - 1.0;

    float3 normal = normalize(input.Normal + normalSample);

    float3 lightDir = normalize(-LightDirection);
    float diffuseFactor = max(dot(normal, lightDir), 0.0);

    float3 diffuse = DiffuseColor * diffuseSample.rgb * LightColor * diffuseFactor * LightIntensity;

    float3 ambient = DiffuseColor * diffuseSample.rgb * 0.1;

    float3 finalColor = ambient + diffuse;
    return float4(finalColor, 1.0);
}