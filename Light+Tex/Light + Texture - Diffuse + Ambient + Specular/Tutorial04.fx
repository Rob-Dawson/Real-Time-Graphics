//--------------------------------------------------------------------------------------
// File: Tutorial04.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D txWoodColour : register(t0);
SamplerState txWoodSampler : register(s0);

cbuffer ConstantBuffer : register( b0 )
{
	matrix World;
	matrix View;
	matrix Projection;
	float3 cameraPos;
}

//--------------------------------------------------------------------------------------
struct VS_INPUT
{
	float4 Pos : POSITION;
	float3 Norm : NORMAL;
	float2 Tex : TEXCOORD0;
};
struct VS_OUTPUT
{
    float4 Pos : SV_POSITION;
	float3 Norm : TEXCOORD1;
	float2 Tex : TEXCOORD2;
	float3 lightVec : TEXCOORD3;
	float3 viewVec : TEXCOORD4;

};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_OUTPUT VS( VS_INPUT input )
{
    VS_OUTPUT output = (VS_OUTPUT)0;
    output.Pos = mul( input.Pos, World );
    output.Pos = mul( output.Pos, View );
    output.Pos = mul( output.Pos, Projection );
	
	output.Tex = input.Tex;
	output.Norm = mul(input.Norm, World);
	output.Norm = normalize(output.Norm);
	//float3 cameraPos = float3(-5.0f, 0.0f, 0.0f);
	float4 worldPos = mul(input.Pos, World);
	output.viewVec = cameraPos.xyz - worldPos.xyz;
	output.viewVec = normalize(output.viewVec);

	return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( VS_OUTPUT input ) : SV_Target
{
	//Problem with the specular lighting
	float specularPower = 1.0f;
	/*=======================================================*/
	float4 ambientColour = float4(0.15f, 1.15f, 0.15f, 1.0f);
	/*=======================================================*/
	float4 diffuseColour = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float3 lightDirection = float3(0.15f, 0.0f, 1.0f); /// GET LECTURER TO CHECK Y
	float4 textureColour = txWoodColour.SampleLevel(txWoodSampler, 1 * input.Tex, 1);
	
	float4 specular = float4(1.0f, 1.0f, 1.0f, 1.0f);

	float4 colour = ambientColour;
	float3 lightDir = -lightDirection;
	float lightIntensity = saturate(dot(input.Norm, lightDir));
	if (lightIntensity > 0.0f)
	{
		colour += (diffuseColour * lightIntensity);
		colour = saturate(colour);
		float3 reflection = normalize(2 * lightIntensity*input.Norm - lightDir);
		specular = pow(saturate(dot(reflection, input.viewVec)), specularPower);
	}

	//colour = saturate(colour);

	colour = colour * textureColour;
	colour = saturate(colour + specular);

	//float4 materialAmb = float4(0.0, 0.0, 0.0, 1.0); 
	//float4 lightCol = float4(1.0, 1.0, 1.0, 1.0);  

	//float3 lightVec = normalize(input.lightVec);
	//float3 normal = normalize(input.Norm); 
	//
	////float diff = clamp(dot(lightVec, float3(0,1,0)),0.0f,1.0f);
	//float diff = clamp(dot(lightVec, normal),0.0f,1.0f);
	//float4 materialDiff = float4(0.9, 0.7, 1.0, 1.0);  
	//float4 specular = 0;

	//if (diff > 0.0f)
	//{
	//	float3 viewVec = normalize(input.viewVec);
	//	float3 halfVec = normalize(lightVec - viewVec);
	//	specular = pow(max(0.0, dot(halfVec, normal)), 1.0f);
	//}
	////float3 outputColour = materialAmb  * materialDiff + diff * lightCol;
	////float4 outputColour = (materialAmb + diff * specular) *lightCol;

	//float3 outputColour = materialAmb + lightCol * diff + lightCol * specular;
	//float4 woodColour = txWoodColour.SampleLevel(txWoodSampler, 1 * input.Tex, 1);
	//float4 light = (materialAmb + diff * diff) *lightCol;
	return colour;
}
