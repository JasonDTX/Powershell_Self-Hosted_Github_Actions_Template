# POWERSHELLSCRIPTNAME

This PowerShell script is designed to [DO STUFF].

## Prerequisites

- PowerShell 5.1 or later
- PSFramework module
- [OTHER DEPENDENCIES HERE]

## Installation

1. [STEP]

    ```powershell
    [Step Commands]
    ```

2. [STEP]

    ```powershell
    [Step Commands]
    ```

## Configuration

The script requires environment variables and a configuration file to provide the necessary credentials and settings.

### Environment Variables

- `office365_creds_usr`: Set this to your application ID.
- `office365_creds_psw`: Set this to your API key.
- [OTHER ENVIRONMENT VARIABLES]

### Configuration File

The `initialize-runnerenvironment.ps1` script is needed to import the configuration file and create Office 365 connection credentials.

Example configuration snippet:

```powershell
$Config = @{
    MicrosoftGraph = @{
        ClientId = "your-client-id"
        Scope = "your-scope"
        TenantId = "your-tenant-id"
    }
}
```

## Usage
Load the initialize function:
```powershell
. .\initialize-runnerenvironment.ps1
```
    
Run the script using the "Initialize-RunnerEnvironment" function:
```powershell
Initialize-RunnerEnvironment -ScriptName '[POWERSHELLSCRIPTNAME.PS1]' -FunctionsPath '[POWERSHELL FUNCTION FOLDER PATH]' -Runscript
```

### Actions Workflow
You can use the actions workflow to execute the script automatically. Ensure your workflow file is configured to set the necessary environment variables and run the initialization script.

### Error Handling
The script includes error handling to log and display errors on console. Errors are logged using the PSFramework and exported to artifacts folder.