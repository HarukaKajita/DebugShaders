#ifndef VECTOR_COMPRESSION_INCLUDED
#define VECTOR_COMPRESSION_INCLUDED

// 量子化された法線毎に適当な色を付けてデバッグ表示するフラグ
#define DEBUG_CLUSTERING_NORMAL_COLOR_OUTPUT 0

#define COMPRESSION_DISABLED 0
#define COMPRESSION_To16bit 1
#define COMPRESSION_To24bit 2
#define COMPRESSION_To32bit 3
uint _CompressionType;

double2 VectorToSolidAngle(double3 cartesian)
{
    //work for vector -z
    double theta = atan2(cartesian.z, cartesian.x); //-pi~pi 
    //float theta = (float)Math.Atan(cartesian.z /cartesian.x);

    double phi = acos(cartesian.y); //0~pi
    return double2(theta, phi);
}

//compression target bits : Number of normals represented　| Number of normals represented on a 90-degree arc on the axis
//16bit :      8128 normals |   127 vertices on arc along x or z axis
//24bit :   2096128 normals |  2047 vertices on arc along x or z axis
//32bit : 536854528 normals | 32767 vertices on arc along x or z axis
#define PI 3.1415926535897932384626433832795
#define HALF_PI 1.5707963267948966192313216916398
#define RESOLUTION_16BIT 126
#define RESOLUTION_24BIT 2046
#define RESOLUTION_32BIT 32766
min16uint EncodeUnitVectorTo16bit(float3 vec)
{
    min16uint compressedValue = 0;
    const float delta_phi = HALF_PI / RESOLUTION_16BIT;
    // 先頭3bitに符号を格納
    if (vec.x < 0)
    {
        compressedValue |= 1 << 15;
        vec.x *= -1;
    }
    if (vec.y < 0)
    {
        compressedValue |= 1 << 14;
        vec.y *= -1;
    }
    if (vec.z < 0)
    {
        compressedValue |= 1 << 13;
        vec.z *= -1;
    }
    // ベクトルの向きを立体角に変換
    const float2 thetaPhi = VectorToSolidAngle(vec);
    // 立体角を解像度で量子化
    const uint i = round(thetaPhi.y / delta_phi);
    const uint j = round(thetaPhi.x * i * 2 / PI);

    const uint n = (i + 1) * i / 2 + j;
    compressedValue |= (uint)n;
    return compressedValue;
}
float3 DecodeUnitVectorFrom16bit(min16uint encode)
{
    const uint n = encode & 0x1FFF;
    const uint i = (sqrt(1 + 8 * n) - 1) / 2;
    const uint j = n - (i + 1) * i / 2;

    // 126 = pow(2, 16bit - 3bit(sign bit))
    const float delta_phi = HALF_PI / RESOLUTION_16BIT;
    const float phi = i * delta_phi;
    const float theta = i > 0 ? j * HALF_PI / i : 0;

    const float sinePhi = sin(phi);
    float3 normal = float3(cos(theta) * sinePhi, cos(phi), sin(theta) * sinePhi);

    if ((encode & 0x8000) != 0) normal.x *= -1;
    if ((encode & 0x4000) != 0) normal.y *= -1;
    if ((encode & 0x2000) != 0) normal.z *= -1;

    if(DEBUG_CLUSTERING_NORMAL_COLOR_OUTPUT)
        return normalize(float3(i%2==0, j%2==0, n%2==0));
    return normalize(normal);
}
uint EncodeUnitVectorTo24bit(float3 vec)
{
    uint compressedValue = 0;
    const float delta_phi = HALF_PI / RESOLUTION_24BIT;
    // 先頭3bitに符号を格納
    if (vec.x < 0)
    {
        compressedValue |= 1 << 23;
        vec.x *= -1;
    }
    if (vec.y < 0)
    {
        compressedValue |= 1 << 22;
        vec.y *= -1;
    }
    if (vec.z < 0)
    {
        compressedValue |= 1 << 21;
        vec.z *= -1;
    }
    // ベクトルの向きを立体角に変換
    const float2 thetaPhi = VectorToSolidAngle(vec);
    // 立体角を解像度で量子化
    const uint i = round(thetaPhi.y / delta_phi);
    const uint j = round(thetaPhi.x * i * 2 / PI);

    const uint n = (i + 1) * i / 2 + j;
    compressedValue |= n;
    return compressedValue;
}
float3 DecodeUnitVectorFrom24bit(uint encode)
{
    const uint n = encode & 0x1FFFFF;
    const uint i = (sqrt(1 + 8 * n) - 1) / 2;
    const uint j = n - (i + 1) * i / 2;

    const float delta_phi = HALF_PI / RESOLUTION_24BIT;
    const float phi = i * delta_phi;
    const float theta = i > 0 ? j * HALF_PI / i : 0;

    const float sinePhi = sin(phi);
    float3 normal = float3(cos(theta) * sinePhi, cos(phi), sin(theta) * sinePhi);

    if ((encode & 0x800000) != 0) normal.x *= -1;
    if ((encode & 0x400000) != 0) normal.y *= -1;
    if ((encode & 0x200000) != 0) normal.z *= -1;

    if(DEBUG_CLUSTERING_NORMAL_COLOR_OUTPUT)
        return normalize(float3(i%2==0, j%2==0, n%2==0));
    return normalize(normal);
}

uint EncodeUnitVectorTo32bit(float3 vec)
{
    uint compressedValue = 0;
    const double delta_phi = HALF_PI / RESOLUTION_32BIT;
    // 先頭3bitに符号を格納
    if (vec.x < 0)
    {
        compressedValue |= 1 << 31;
        vec.x *= -1;
    }
    if (vec.y < 0)
    {
        compressedValue |= 1 << 30;
        vec.y *= -1;
    }
    if (vec.z < 0)
    {
        compressedValue |= 1 << 29;
        vec.z *= -1;
    }
    // ベクトルの向きを立体角に変換
    const double2 thetaPhi = VectorToSolidAngle(vec);
    // 立体角を解像度で量子化
    const uint i = round(thetaPhi.y / delta_phi);
    const uint j = round(thetaPhi.x * i * 2 / PI);

    const uint n = (i + 1) * i / 2 + j;
    compressedValue |= n;
    return compressedValue;
}
float3 DecodeUnitVectorFrom32bit(uint encode)
{
    const uint n = encode & 0x1FFFFFFF;
    uint i = (sqrt(1 + 8 * n) - 1) / 2;
    int j = n - (i + 1) * i / 2;
    // modify index which is incorrect result infuluenced by float-precision sqrt.
    if (j < 0) { j += i; i--; }
    
    const double delta_phi = HALF_PI / RESOLUTION_32BIT;
    const double phi = i * delta_phi;
    const double theta = i > 0 ? j * HALF_PI / i : 0;

    const double sinePhi = sin(phi);
    float3 normal = float3(cos(theta) * sinePhi, cos(phi), sin(theta) * sinePhi);

    if ((encode & 0x80000000) != 0) normal.x *= -1;
    if ((encode & 0x40000000) != 0) normal.y *= -1;
    if ((encode & 0x20000000) != 0) normal.z *= -1;

    if(DEBUG_CLUSTERING_NORMAL_COLOR_OUTPUT)
        return normalize(float3(i%2==0, j%2==0, n%2==0));
    return normalize(normal);
}

#endif