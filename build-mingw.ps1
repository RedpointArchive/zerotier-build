param()

$ErrorActionPreference = "Stop"

function RemoveMSVCFlags($Path) {
    $Content = (Get-Content -Raw $Path)
    $Content = $Content.Replace("/EHsc", "")
    $Content = $Content.Replace("/W3 /MP", "")
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
    $env:CXXFLAGS="-fpermissive"
    cmake -G "MinGW Makefiles" ..\libzt
    mingw32-make zto zto_pic
} finally {
    Pop-Location
}