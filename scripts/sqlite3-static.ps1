Write-Output "Configuring Build Tools..."
$vsbase = vswhere.exe -products * -property installationPath

Write-Output "Resolving SQLite3 distribution..."
$sqlite_info = Invoke-WebRequest -Uri 'https://www.sqlite.org/download.html' -UseBasicParsing
$sqlite_info -match 'PRODUCT,(?<version>\d+\.\d+\.\d+),(?<url>(?<year>\d+)/sqlite-amalgamation-(?<rev>\d+).zip)'
$sqlite_sources = "https://www.sqlite.org/" + $Matches.url
$sqlite_dir = "/sqlite/sqlite-amalgamation-" + $Matches.rev

Write-Output "Downloading SQLite sources: $sqlite_sources"
mkdir /sqlite
pushd /sqlite
Invoke-WebRequest -Uri $sqlite_sources -OutFile sqlite.zip -UseBasicParsing
Expand-Archive -Path sqlite.zip -DestinationPath .
popd

Write-Output "Building SQLite3 static lib..."
pushd $sqlite_dir
$cmdline = '"' + $vsbase + '\VC\Auxiliary\Build\vcvars64.bat" && cl /c /EHsc sqlite3.c && lib sqlite3.obj'
& "cmd" "/C" "$cmdline"
popd

Write-Output "Copying SQLite3 static lib to $(crystal env CRYSTAL_LIBRARY_PATH)..."
$src = "$sqlite_dir/sqlite3.lib"
$dest = (crystal env CRYSTAL_LIBRARY_PATH) + '/sqlite3-static.lib'
cp "$src" "$dest"

Write-Output "Cleaninig up SQLite3 sources..."
rm -r /sqlite
