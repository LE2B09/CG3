#include "Object3d.hlsli"

// マテリアル
struct Material
{
    float4 color;
    int enableLighting;
    float4x4 uvTransform;
    float shininess;
};

//平行光源
struct DirectionalLight
{
    float4 color; //!< ライトの色
    float3 direction; //ライトの向き
    float intensity; //輝度
};

// カメラの位置を送る
struct Camera
{
    float3 worldPosition;
};

//ピクセルシェーダーの出力
struct PixelShaderOutput
{
    float4 color : SV_TARGET0;
};

ConstantBuffer<Material> gMaterial : register(b0);
Texture2D<float4> gTexture : register(t0);
SamplerState gSampler : register(s0);
ConstantBuffer<DirectionalLight> gDirectionalLight : register(b1);
ConstantBuffer<Camera> gCamera : register(b2);

//ピクセルシェーダー
PixelShaderOutput main(VertexShaderOutput input)
{
    //TextureをSamplingする
    float4 transformedUV = mul(float4(input.texcoord, 0.0f, 1.0f), gMaterial.uvTransform);
    float4 textureColor = gTexture.Sample(gSampler, transformedUV.xy);
    
    float3 toEye = normalize(gCamera.worldPosition - input.worldPosition);
    
    // 入射校の反射ベクトルを求める
    float3 reflectLight = reflect(gDirectionalLight.direction, normalize(input.normal));
    
    float NdotL = dot(normalize(input.normal), -gDirectionalLight.direction);
    float cos = pow(NdotL * 0.5f + 0.5f, 2.0f);
        
    // 内積をとり、saturateし、shininess階乗すると鏡面反射の強度が求まる
    float RdotE = dot(reflectLight, toEye);
    float specularPow = pow(saturate(RdotE), gMaterial.shininess); // 反射強度
    
    PixelShaderOutput output;
    
    //Lightingする場合
    if (gMaterial.enableLighting != 0)
    {
        // 拡散反射
        float3 diffuse = gMaterial.color.rgb * gDirectionalLight.color.rgb * cos * gDirectionalLight.intensity;
        // 鏡面反射
        float3 specular = gDirectionalLight.color.rgb * gDirectionalLight.intensity * specularPow * float3(1.0f, 1.0f, 1.0f);
        // 拡散反射 + 鏡面反射
        output.color.rgb = diffuse + specular;
    
        // RGBにはライティングを適用
        output.color.rgb = gMaterial.color.rgb * textureColor.rgb * gDirectionalLight.color.rgb * cos * gDirectionalLight.intensity;
        // α値にはライティングを適用しない
        output.color.a = gMaterial.color.a * textureColor.a;
    }
    else
    {
        //Lightingしない場合、前回までと同じ演算
        output.color = gMaterial.color * textureColor;
    }
    
    
// textureのα値が0.5以下のときにPixelを棄却
    if (textureColor.a <= 0.5)
    {
        discard;
    }
    
    // textureのα値が0の時にPixelを棄却
    if (textureColor.a == 0.0)
    {
        discard;

    }
    
    // output.colorのα値が0の時にPixelを棄却
    if (output.color.a == 0.0)
    {
        discard;
    }
    
    return output;
}
