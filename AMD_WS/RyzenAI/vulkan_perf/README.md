#### vulkanを使ったVK_KHR_cooperative_matrixパフォーマンスチェック 

Windows11/RDNA3以降  

Required  
- Vulkan SDK for Windows  
- Visual Studio 2026 Community  
- Cmake for Windows  
- Git for Windows  

> vulkaninfo --show-all | findstr /i cooperative_matrix

```  
WARNING: [Loader Message] Code 0 : Layer VK_LAYER_AMD_switchable_graphics uses API version 1.3 which is older than the application specified API version of 1.4. May cause issues.
        VK_KHR_cooperative_matrix                   : extension revision 2
```  

##### VH_KHR_cooperative_matrix_perfをクローンする  
> git clone https://github.com/jeffbolznv/vk_cooperative_matrix_perf.git  
> cd vk_cooperative_matrix_perf  
  
cmake -S . -B build -G "Visual Studio 18 2026" -A x64  
cmake --build build --config Release  

##### パフォーマンス測定  
.\build\Release\vk_cooperative_matrix_perf.exe  
##### もし正しさ検証もしたければ  
.\build\Release\vk_cooperative_matrix_perf.exe --correctness  
