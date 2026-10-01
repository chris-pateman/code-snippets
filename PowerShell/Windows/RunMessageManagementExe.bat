Setlocal EnableDelayedExpansion
set ScriptName=%1
set ScriptPath=%2
set ScriptArguments=%3
set ScriptArguments=%ScriptArguments:"=%
set ScriptArguments=%ScriptArguments:<=|%

set CORECLR_PROFILER_PATH_64_value="%ScriptPath%\AppDynamics.Profiler_x64.dll"
setx CORECLR_PROFILER_PATH_64 "%CORECLR_PROFILER_PATH_64_value%" /M
setx CORECLR_PROFILER_PATH_64 "%CORECLR_PROFILER_PATH_64_value%"

set CORECLR_PROFILER_PATH_32_value="%ScriptPath%\AppDynamics.Profiler_x86.dll"
setx CORECLR_PROFILER_PATH_32 "%CORECLR_PROFILER_PATH_32_value%" /M
setx CORECLR_PROFILER_PATH_32 "%CORECLR_PROFILER_PATH_32_value%"

cd %ScriptPath%
%ScriptName% "Feedback|2" "RequestABrochure|2" "Depot|2" "Registration|2" "KitchenVisualiser|2"