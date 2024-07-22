<# 
https://github.com/Jaykul/RequiredModules/blob/main/source/Public/Install-RequiredModule.ps1
The RequiredModules list looks like this (uses nuget version range syntax, and now, has an optional syntax for specifying the repository to install from):
    @{
        "PowerShellGet" = "2.0.4"
        "Configuration" = "[1.3.1,2.0)"
        "Pester"        = "[4.4.2,4.7.0]"
        "ModuleBuilder"    = @{
            Version = "2.*"
            Repository = "https://www.powershellgallery.com/api/v2"
        }
    }
    https://docs.microsoft.com/en-us/nuget/reference/package-versioning#version-ranges-and-wildcards
#>
@{  
    #"PowerShellGet"    = "2.2.5"
    #"ServiceNow"    = "3.0"
    #"PSFramework"    = "1.10.318"
    #"PnP.PowerShell" = "1.12.0"
    #"ExchangeOnlineManagement" = "3.2.0"
    #"Az.Accounts" = "3.0.0"
    #"Microsoft.Graph.Mail" = "2.19.0"
    #"Microsoft.Graph.Users" = "2.19.0"
    #"Microsoft.Graph.DirectoryObjects" = "2.19.0"
    #"Microsoft.Graph.Authentication" = "2.19.0"
    #"Microsoft.Graph.Groups" = "2.19.0"
    
}
