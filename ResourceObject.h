#pragma once
#include <d3d12.h>
#pragma comment(lib,"d3d12.lib")

// 自動Relese解放マン
class ResourceObject
{
public:
	ResourceObject(ID3D12Resource* resource) : resource_(resource) {};
	// デストラクタはオブジェクトの寿命が尽きた時に呼ばれる
	~ResourceObject()
	{
		//Releseを呼べばいい
		if (resource_)
		{
			resource_->Release();
		}
	};
	ID3D12Resource* Get() { return resource_; }
private:
	ID3D12Resource* resource_;
};

