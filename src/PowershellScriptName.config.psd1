@{
    'MicrosoftGraph'    = @{ # Example of a Microsoft Graph configuration
        'ClientId'     = ' ' # Application ID
        'TenantId'     = ' ' # Tenant ID
        'Scope'        = @("Directory.Read.All", "User.Read.All") # Required scopes for operations, customize as needed
        
    }
    'MessageParameters' = @{ # Incident alerting parameters, this is for sending mails to the automation alerts teams channel
        'To'          = ' ' # email address to send alert to
        'From'        = ' ' # customize as needed
        'Body'        = ' ' # customize as needed
        'Subject'     = ' ' # customize as needed
        'SMTPServer'  = ' ' # SMTP server
        'Priority'    = 'High'
        'BodyAsHTML'  = $True
        'ErrorAction' = 'Stop'
    }
    'ServiceNow'        = @{ # ServiceNow configuration for incidents, email used as failover
        'URL'                    = ' ' # ServiceNow URL
        'Incident'               = @{
            # Utilizes New-ServiceNowIncident function which uses common parameter names including CustomFields which uses ServiceNow property names
            'AssignmentGroup'   = ' ' # Service now assignment group for incident
            'Caller'            = ' ' # Account name of the user who reported the incident
            'Category'          = ' ' # ServiceNow category for incident
            'Description'       = ' ' # Description of the incident
            'ShortDescription'  = 'Powershell Job Failure'
        }
        'IncidentOverride'       = @{} # Optional override for New-ServiceNowIncident function, similar to servicenow configuration above
        'ServiceRequestOverride' = @{} # Optional override for New-ServiceNowServiceRequest function, similar to servicenow configuration above
    }
}