Write-Host 'Cleaning previous build output...'
Remove-Item -Path ./src/FluentUIApp/obj -Recurse -Force
Remove-Item -Path ./src/FluentUIApp/bin -Recurse -Force

Write-Host 'Building the app...'
dotnet build -c Release
Write-Host 'Publishing the app with --no-build...'
dotnet publish --no-build

# Test for the expected file
$expectedFile = './src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json'
Write-Host "Testing for expected file ($expectedFile):"
if (Test-Path $expectedFile) {
    Write-Host 'Behaving as expected!' -ForegroundColor Green
}
else {
    Write-Host 'Expected file doesn''t exist. This is the bug!' -ForegroundColor Red
}

# Test for the filename that appears instead
$bugFile = './src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json'
Write-Host "Testing for bug file ($bugFile):"
if (Test-Path $bugFile) {
    Write-Host 'The bug file exists. This is the bug!' -ForegroundColor Red
}
else {
    Write-Host 'The bug file doesn''t exist. This is the expected behavior.' -ForegroundColor Green
}