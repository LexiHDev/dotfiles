if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}


#example program, this will be ran as admin
Write-Output("Beginning Installer.");

timeout.exe /t 5;
# winget import -i $PSScriptRoot\winget.json --disable-interactivity
[string]$userInput = Read-Host("Would you like to run the setup? (Y/N)");

if (($userInput = "Y") -or ($userInput = "")) {
    Write-Output("Enabling sudo");
    sudo config --enable normal
    Write-Output("Set Firefox as Default Browser...");
    Start-Process 'C:\Program Files\Mozilla Firefox\uninstall\helper.exe' /SetAsDefaultAppGlobal
    $settingsFilePath = $env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    $json = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json -ErrorAction Stop

    # Remove previous nushell profiles this command is annoying as heck
    $json.profiles.list = @($json.profiles.list | Where-Object { ($_.commandline -ne 'nu.exe') -and ($_.commandline -ne 'nu') })
    
    $newProfile = [PSCustomObject]@{
        guid        = '{00000000-0000-0000-0000-000000000000}'
        hidden      = $false
        name        = "My Nushell"
        commandline = "nu.exe"
    }
    $json.profiles.list += $newProfile
    $json.defaultProfile = $newProfile.guid
    $json | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsFilePath -Force
    Write-Host "'My Nushell' profile has been created and set as the default."
    
    [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME",$env:USERPROFILE + "\.config\", "User");

    Write-Host "Installing NerdFont Source Code Pro via https://github.com/vatsan-madhavan/NerdFontInstaller"
    git.exe clone https://github.com/vatsan-madhavan/NerdFontInstaller
    .\NerdFontInstaller\NerdFontInstaller.ps1 -Font SourceCodePro
}

timeout.exe /t 30;

