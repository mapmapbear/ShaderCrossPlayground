add_rules("mode.debug", "mode.release")
set_languages("c++23")
set_runtimes("MD")

add_requires("spirv-cross", {configs = {shared = true}})

target("spirv-reflect")
    set_kind("static") -- 编译为动态库
    local vulkan_sdk = os.getenv("VULKAN_SDK")
    local reflect_dir = path.join(vulkan_sdk, "Source/SPIRV-Reflect")
    add_files(path.join(reflect_dir, "spirv_reflect.c"))
    add_includedirs(reflect_dir)
    set_runtimes("MD") -- 使用 /MD
    -- if is_mode("debug") then
    --     set_runtimes("MDd") -- 调试模式使用 /MDd
    -- end


target("ShaderPlayground")
    set_kind("binary")
    add_packages("spirv-cross")
    add_deps("spirv-reflect")
    local vulkan_sdk = os.getenv("VULKAN_SDK")
    local vlkanSDKInclude = path.join(vulkan_sdk, "include")
    local vulkanSDKLib = path.join(vulkan_sdk, "Lib")
    add_includedirs(vlkanSDKInclude, path.join(vulkan_sdk, "Source/SPIRV-Reflect"))
    add_linkdirs(vulkanSDKLib)
    -- dxc
    add_links("dxcompiler.lib")
    -- glslang
    add_links("glslang.lib", "MachineIndependent.lib", "SPIRV.lib", "GenericCodeGen.lib")
    -- spirv-tools
    add_links("SPIRV-Tools.lib", "SPIRV-Tools-opt.lib")
    add_files("*.cpp")

target("ShaderCompiler")
    set_kind("phony") -- 这里可以是 phony，避免 xmake 生成实际的二进制文件
    set_default(false) -- 让它不在默认 `xmake build` 触发
    add_files("shaders/**.hlsl")
    on_build(function (target)
        import("lib.detect.find_tool")
        local dxc = assert(find_tool("dxc"), "dxc not found!")
        local shaderMakePath = path.join(os.scriptdir(), "/ShaderMake.exe")
        local shader_output_path = path.join(target:targetdir(), "_Shaders")
        os.mkdir(shader_output_path)
        local args1 = {
            "--useAPI", "--binary", "--flatten", "--stripReflection", "--WX", "--PDB",
            "--sRegShift", "100", "--tRegShift", "200", "--bRegShift", "300", "--uRegShift", "400",
            "--sourceDir", path.join(os.scriptdir(), "Shaders"),
            "-c", path.join(os.scriptdir(), "Shaders.cfg"),
            "-o", shader_output_path,
            "-p", "SPIRV", "--compiler", dxc.program
        }
        os.execv(shaderMakePath, args1)
    end)