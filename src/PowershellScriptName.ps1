<#
.SYNOPSIS
    INSERT SYNOPSIS HERE
.DESCRIPTION
    INSERT DESCRIPTION HERE
.PARAMETER ScriptName
    The name of the script that is running.  This is used to load the configuration file.
.PARAMETER parametername
	INSERT PARAMETER DESCRIPTION HERE
.PARAMETER parametername2
	INSERT PARAMETER DESCRIPTION HERE
.EXAMPLE
	INSERT EXAMPLE DESCRIPTION HERE
#>
[CmdletBinding()]
Param ( # Simple Example Parameters below
    [Parameter(HelpMessage = "The name of the script that is running.  This is used to load the configuration file.")]
    [string]$ScriptName,
    
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "INSERT HELP MESSAGE HERE")]
    [string]$parametername,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "INSERT HELP MESSAGE HERE")]
    [string]$parametername2
)
Begin {
    # Do not place any code above the Begin block
    # Use begin block to initialize variables and logging. (If this script is run by the initializer function, logging will already be started)

    $ErrorCount = 0 # Initialize error count, for tracking errors
    
    # Use regions to separate code sections
    #region REGIONNAME
    Try {
        # Script template calls a config psd1 file with the same name as the script.  If the config is not loaded, load it here.
        # Using a configuration psd1 avoids hardcoding values in the script and allows for easy configuration changes.

        If (-Not $Config) {
            # If using the Initialize-RunnerEnvironment function, config is passed in as global variable

            # The scriptname is required to load the configuration.
            # If the script name is not set, try to use the name of the script that is running
            If ( [string]::IsNullOrEmpty($ScriptName)) {
                Write-Debug "ScriptName is null or empty.  Attempting to set the ScriptName from the script that is running."
                
                # Attempt to set the script name from the script that is running
                If ( -Not [string]::IsNullOrEmpty($MyInvocation.MyCommand.Name)) {
                    # The invocation command name may not be available in all scenarios
                    $Global:ScriptName = $MyInvocation.MyCommand.Name
                }
            }

            # Load the Config file and set the Config variable
            Write-Debug "Importing Configuration for $ScriptName."
        
            # Replace the script name with the config name
            $Global:ConfigPath = Join-Path -Path ".\" -ChildPath $ScriptName.Replace('.ps1', '.Config.psd1')

            $Global:Config = Import-PowershellDataFile -Path $ConfigPath -ErrorAction Stop
            Write-Debug "Configuration imported successfully."
        }
        
        # INSERT ANY OTHER BEGIN BLOCK CODE HERE, SUCH AS LOGGING INTO A SERVICE, INITIALIZING A CONNECTION, SETTING VARIABLES ETC.
    }
    Catch {
        #### Log failure using PSFramework
        $writePSFMessageSplat = @{
            Level       = 'Critical'
            Message     = $PSItem.Exception.Message
            Tag         = 'Error', 'NotificationError'
            ErrorRecord = $PSItem
        }
        Write-PSFMessage @writePSFMessageSplat
        Write-Host -BackgroundColor Red -ForegroundColor White "Error: $($PSItem.Exception.Message)"
        $ErrorCount ++ # When there is an error, just increment the error count, the error will be thrown in the end block
        # (Use a throw if the script cannot run further without the Begin block)
    }
    #endregion REGIONNAME 
    # Don't forget to close the region

}

Process {
    # Use process block to handle the main processing of the script

    # Use regions to separate code sections
    #region REGIONNAME2
    Try {
        # INSERT MAIN PROCESSING CODE HERE
    }
    Catch {
        #### Log failure
        $writePSFMessageSplat = @{
            Level       = 'Critical'
            Message     = $PSItem.Exception.Message
            Tag         = 'Error', 'NotificationError'
            ErrorRecord = $PSItem
        }
        Write-PSFMessage @writePSFMessageSplat
        Write-Host -BackgroundColor Red -ForegroundColor White "Error: $($PSItem.Exception.Message)"
        $ErrorCount ++ # When there is an error, just increment the error count, the error will be thrown in the end block
    }
    #endregion REGIONNAME2
    # Don't forget to close the region
}

End {
    # Use end block to handle any final processing, error handling, and cleanup
    
    # Use regions to separate code sections
    #region ERRORHANDLING
    Try {
        # Make sure scriptname exists for creating ticket subject line
        If ($null -eq $scriptname -or $scriptname -notlike "*.ps1") {
            If ( $null -ne $BuildScript) { $scriptName = $BuildScript }
            ElseIf ($null -ne $env:scriptname) { $scriptName = $env:scriptName }
            Else { $scriptname -eq "$($PSItem.InvocationInfo.ScriptName)" }
        }
        # Make sure the application ID and api secret are available
        If ($Env:ManageEngineClientID) { $Config.ManageEngine.ClientID = $Env:ManageEngineClientID }
        If ($Env:ManageEngineClientSecret) { $Config.ManageEngine.ClientSecret = $Env:ManageEngineClientSecret }
        
        # If they are not available throw to email failover
        If ($null -eq $Config.ManageEngine.ClientID -or $null -eq $Config.ManageEngine.ClientSecret) {
            Write-PSFMessage -Level Error -Message "ManageEngine ClientID or ClientSecret not found in configuration"
            Throw "ManageEngine ClientID or ClientSecret not found in configuration"
        }
        # Create base splat for case creation
        $invokeManageEngineRequest = @{
            ClientID        = $Config.ManageEngine.ClientID
            ClientSecret    = $Config.ManageEngine.ClientSecret
            Scope           = $Config.ManageEngine.ClientScope
            OAuthUrl        = $Config.ManageEngine.OAuthUrl
            ManageEngineUri = $Config.ManageEngine.ManageEngineUri
        }
        # If there are no errors, create a resolved service desk ticket to log the success
        If ($ErrorCount -eq 0) {
            Write-PSFMessage "Opening Success Service-Desk request"
            ## Create ManageEngine config with success variables
            $Config.ManageEngine = $Config.ManageEngine.SuccessTicket
        }
        # If there are errors, create an open service desk ticket to Automation Team
        If ($ErrorCount -gt 0) {
            Write-PSFMessage "Opening Error Service-Desk request"
            ## Create ManageEngine config with error variables
            $Config.ManageEngine = $Config.ManageEngine.ErrorTicket
        }
        # Add the config to the splat
        $Config.ManageEngine.Subject = "$($Config.ManageEngine.Subject) - $($scriptName)"
        $Config.ManageEngine.Description = $Config.ManageEngine.Description -f $errorcount, $scriptName, $Env:ComputerName, "$serverUrl/$repository/actions/runs/$runId"
        
        # Add the config to the splat
        $invokeManageEngineRequest.Config = $Config.ManageEngine
        
        # Attach artifacts if exists
        If (Test-Path $Artifacts) {
            If (-Not (Test-Path "$Artifacts\IncidentLogs")) {
                $null = New-Item -Path "$Artifacts\IncidentLogs" -ItemType Directory
            }
            $Attachments = Get-ChildItem -Path $Artifacts -File | ForEach-Object {
                $FileNewPath = Join-Path -Path $Artifacts -ChildPath "IncidentLogs\$($_.Name)"
                Copy-Item -Path $_.FullName -Destination $FileNewPath -Force
                $FileNewPath
            }
        }
        # Add the attachments to the splat
        If ($null -ne $Attachments) {
            $invokeManageEngineRequest.AttachmentPath = $Attachments
        }
        # Create the ticket
        $null = Invoke-ManageEngineRequest @invokeManageEngineRequest

    }
    Catch {
        $PSItem
        ### Trigger an email failover if incident creation fails
        $EmailFailover = $True
    }
    Finally {
        ## Handle email notification as a failover if necessary.
        If ($EmailFailover -eq $True) {
            Try {
                $MessageParameters = $Config.MessageParameters
                $MessageParameters.From = $MessageParameters.From -f $scriptName
                $MessageParameters.Subject = $MessageParameters.Subject -f $scriptName
                $MessageParameters.Body = $Config.MessageParameters.Body -f $errorcount, $scriptName, $Env:ComputerName, "$serverUrl/$repository/actions/runs/$runId"
                Send-MailMessage @MessageParameters
                Write-PSFMessage 'Email notification sent'
            }
            Catch {
                $ErrorCount ++
                Write-Error $PSItem
            }
        }
    }    
    If ($ErrorCount -eq 0) {
        Exit 0
    }
    If ($ErrorCount -gt 0) {
        $ErrorMessage = "A total of [{0}] errors were logged.  Please view logs for details." -f $ErrorCount
        Write-PSFMessage -Level Error -Message $ErrorMessage
        Exit 1
    }
    #endregion ERRORHANDLING
    # Don't forget to close the region

    # You can put any other final code here
}