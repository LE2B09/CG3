#pragma once
#include "Vector3.h"
#include "Vector4.h"

///==========================================================
/// DirectionalLightを拡張
///==========================================================
struct DirectionalLight final
{
	Vector4 color;		//!< ライトの色
	Vector3 direction;	//!< ライトの向き
	float intensity;	//!< 輝度
};
///==========================================================
/// DirectionalLightを拡張
///==========================================================