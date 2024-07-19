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

        If (-Not $Config) { # If using the Initialize-RunnerEnvironment function, config is passed in as global variable

            # The scriptname is required to load the configuration.
            # If the script name is not set, try to use the name of the script that is running
            If ( [string]::IsNullOrEmpty($ScriptName)) {
                Write-Debug "ScriptName is null or empty.  Attempting to set the ScriptName from the script that is running."
                
                # Attempt to set the script name from the script that is running
                If ( -Not [string]::IsNullOrEmpty($MyInvocation.MyCommand.Name)) { # The invocation command name may not be available in all scenarios
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
        If ($ErrorCount -gt 0) {
            # If errors are logged, throw an error with the count
            $ThrowMessage = "A total of [{0}] errors were logged.  Please view logs for details." -f $ErrorCount
            Throw $ThrowMessage
        }
    }
    Catch {
        # Catch the throw above and create an incident
        $PSItem
        ## Create ServiceNow ticket with error variables
        $Config.ServiceNow.Incident.Description += $PSItem.Exception.Message
        Try {
            If ($SNowCredential){
                $invokeServiceNowIncidentSplat = @{
                    Config      = $Config
                    Credential  = $SNowCredential
                    PassThru    = $true
                    ErrorAction = 'Stop'
                    Verbose     = $false
                }
                $Ticket = Invoke-ServiceNowIncident @invokeServiceNowIncidentSplat
    
                ### Get the PSFramework logging logfile configuration and make it a path to attach the log to ServiceNow
                $LogPath = Get-PSFConfigValue -FullName 'PSFramework.Logging.LogFile.FilePath'
                $LogName = Get-PSFConfigValue -FullName 'PSFramework.Logging.LogFile.LogName'
                $LogFilePath = $LogPath.Replace('%logname%', $LogName)
    
                ### Attach log file if it exists
                If (Test-Path $LogFilePath) {
                    Set-PSFLoggingProvider -Name Logfile -Enabled $false
                    $addServiceNowAttachmentSplat = @{
                        ID          = $Ticket.Number
                        Table       = 'incident'
                        File        = $LogFilePath
                        Verbose     = $false
                        ErrorAction = 'Stop'
                    }
                    Add-ServiceNowAttachment @addServiceNowAttachmentSplat
                    Set-PSFLoggingProvider -Name Logfile -Enabled $true
                }
            }
            Else { $EmailFailover = $True }
        }
        Catch {
            $PSItem
            ### Trigger an email failover if incident creation fails
            $EmailFailover = $True
        }
    }
    Finally {
        ## Handle email notification as a failover if necessary.
        If ($EmailFailover -eq $True) {
            Try {
                $MessageParameters = $Config.MessageParameters
                Send-MailMessage @MessageParameters
                Write-Verbose 'Email notification sent'
            }
            Catch {
                Write-Error $PSItem
            }
        }
    }
    #endregion ERRORHANDLING 
    # Don't forget to close the region

    # You can put any other final code here
}