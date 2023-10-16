Set-ExecutionPolicy Bypass -Scope LocalMachine
$ProgressPreference = "SilentlyContinue"

Write-Output "Installing the Scoop package manager..."
irm get.scoop.sh -outfile 'install-scoop.ps1'
& "install-scoop.ps1" -RunAsAdmin
rm "install-scoop.ps1"

Write-Output "Installing Crystal & dev tools ..."
scoop install git
scoop bucket add crystal-preview "https://github.com/neatorobito/scoop-crystal"
scoop install vs_2022_cpp_build_tools
scoop install crystal

& "scripts/sqlite3-static.ps1"
