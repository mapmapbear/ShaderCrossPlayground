#include "ShaderTranspiler.h"
#include <iostream>

using namespace std;

// the library's namespace
using namespace shadert;

int main() {

  // create an instance
  ShaderTranspiler s;

  CompileTask task{"_Shaders/testLighting.fs.spirv", ShaderStage::Fragment};

  Options opt;

  try {
    // call CompileTo and pass the CompileTask and the Options
    CompileResult result = s.Compile(task, TargetAPI::Metal, opt);
    const string shaderCode = result.data.sourceData;
    std::cout << result.data.sourceData << std::endl;
  } catch (exception &e) {
    std::cout << e.what() << std::endl;
    return 1;
  }

  return 0;
}
