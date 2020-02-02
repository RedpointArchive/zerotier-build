param()

$ErrorActionPreference = "Stop"

function RemoveMSVCFlags($Path) {
    $Content = (Get-Content -Raw $Path)
    $Content = $Content.Replace("/EHsc", "")
    $Content = $Content.Replace("/W3 /MP", "")
    Set-Content -Path $Path -Value $Content
}

function FileReplace($Path, $Old, $New) {
    $Content = (Get-Content -Raw $Path)
    $Content = $Content.Replace($Old, $New)
    Set-Content -Path $Path -Value $Content
}

function FileAppend($Path, $New) {
    $Content = (Get-Content -Raw $Path)
    $Content += "`n$New"
    Set-Content -Path $Path -Value $Content
}

$Paths = ($env:PATH).Split(";")
$NewPaths = @()
foreach ($Path in $Paths) {
    if (Test-Path "$Path\sh.exe") {
        continue
    }
    $NewPaths += $Path
}
$env:PATH = $NewPaths -join ";"

if (Test-Path $PSScriptRoot\build) {
    Remove-Item -Force $PSScriptRoot\build
}
mkdir $PSScriptRoot\build
Push-Location $PSScriptRoot\build
try {
    RemoveMSVCFlags $PSScriptRoot\libzt\CMakeLists.txt
    RemoveMSVCFlags $PSScriptRoot\libzt\zto\java\CMakeLists.txt
    FileReplace $PSScriptRoot\libzt\include\libzt.h "#include <cstdint>" "#include <stdint.h>`n#if defined(GOLANG_CGO)`n#define bool int`n#endif"
    FileReplace $PSScriptRoot\libzt\include\libztDebug.h "#if defined(_WIN32)" "#if !defined(_WIN32)"
    FileReplace $PSScriptRoot\libzt\include\libztDebug.h "#define LIBZT_DEBUG_HPP" "#define LIBZT_DEBUG_HPP`n#define LIBZT_DEBUG 1`n#define LIBZT_TRACE 1`n"
    FileAppend $PSScriptRoot\libzt\CMakeLists.txt 'add_library(ztunified STATIC ${lwip_src_glob} ${zto_src_glob} "${ZTO_SRC_DIR}/ext/http-parser/http_parser.c" ${libzt_src_glob})'
    $env:CFLAGS="-DLIBZT_DEBUG=1 -DLIBZT_TRACE=1"
    $env:CXXFLAGS="-fpermissive -DLIBZT_DEBUG=1 -DLIBZT_TRACE=1"
    cmake -G "MinGW Makefiles" ..\libzt
    mingw32-make ztunified
} finally {
    Pop-Location
}