# ASP.NET Core Issue 58321

This repository is a repro for <https://github.com/dotnet/aspnetcore/issues/58321>.

## Pre-requisites

* [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
* [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)

## Explanation

After changing from the .NET 8 SDK to the .NET 9 SDK, publishing an application
using `--no-build` results in an incorrectly named file being placed in the
`wwwroot` folder. For example, `jsmodules.publish.manifest.json` instead of
`FluentUIApp.modules.json`. Same content, but wrong file name. This causes the
content to break at runtime.

## To re-create the repro source

To setup the source code to reproduce this issue yourself:

```powershell
mkdir aspnet-58321-repro
cd aspnet-58321-repro
dotnet new globaljson # Expected to be configured with version 9.0.100-rc.2.24474.11
dotnet new install Microsoft.FluentUI.AspNetCore.Templates
dotnet new fluentblazor -o src\FluentUIApp
```

The code above, at the time of writing, produces:

* A `global.json` file configured with `"version": "9.0.100-rc.2.24474.11"`.
* A .NET 8 Blazor project configured for Fluent UI.

## Repro steps

### Scripted steps

Run `.\repro.ps1` using PowerShell and you should see the following at the end
of the output:

```text
Testing for expected file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json):
Expected file doesn't exist. This is the bug!
Testing for bug file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json):
The bug file exists. This is the bug!
```

Now, update the `global.json` file with a .NET 8 SDK version:

```json
{
  "sdk": {
    "version": "8.0.403"
  }
}
```

Run `.\repro.ps1` using PowerShell again and you should se the following at the
end of the output:

```text
Testing for expected file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json):
Behaving as expected!
Testing for bug file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json):
The bug file doesn't exist. This is the expected behavior.
```

### Manual steps

To run the steps manually yourself, run the following:

```powershell
dotnet build -c Release
dotnet publish --no-build
# Now check for the existence of:
#  Expected: ./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json
#  Actual  : ./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json
```

## Results

### Actual

The `./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/smodules.publish.manifest.json` file exists instead.

```text
> .\repro.ps1
Cleaning previous build output...
Building the app...
Restore complete (0.5s)
You are using a preview version of .NET. See: https://aka.ms/dotnet-support-policy
  FluentUIApp succeeded (0.9s) → src\FluentUIApp\bin\Release\net8.0\FluentUIApp.dll

Build succeeded in 1.6s
Publishing the app with --no-build...
  FluentUIApp succeeded (0.3s) → src\FluentUIApp\bin\Release\net8.0\publish\

Build succeeded in 0.4s
Testing for expected file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json):
Expected file doesn't exist. This is the bug!
Testing for bug file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json):
The bug file exists. This is the bug!
```

### Expected

The `./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json` file should exist.

```text
> .\repro.ps1
Cleaning previous build output...
Building the app...
Restore complete (0.5s)
You are using a preview version of .NET. See: https://aka.ms/dotnet-support-policy
  FluentUIApp succeeded (0.9s) → src\FluentUIApp\bin\Release\net8.0\FluentUIApp.dll

Build succeeded in 1.6s
Publishing the app with --no-build...
  FluentUIApp succeeded (0.3s) → src\FluentUIApp\bin\Release\net8.0\publish\

Build succeeded in 0.4s
Testing for expected file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/FluentUIApp.modules.json):
Behaving as expected!
Testing for bug file (./src/FluentUIApp/bin/Release/net8.0/publish/wwwroot/jsmodules.publish.manifest.json):
The bug file doesn't exist. This is the expected behavior.
```
