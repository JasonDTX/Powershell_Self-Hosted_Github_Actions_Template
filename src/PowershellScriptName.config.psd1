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
    'ManageEngine' = @{
        'clientScope'     = 'SDPOnDemand.requests.ALL' # Required scope for 'request' operations, customize as needed
        'oauthUrl'        = 'https://accounts.zoho.com/oauth/v2/token' # OAuth URL
        'manageengineUri' = 'https://sdpondemand.manageengine.com/app/itdesk/api/v3/requests' # ManageEngine request URL
        'requester'       = ' ' # Requester email
        'category'        = ' ' # Request category
        'impact'          = 'Low' # Request impact
        'subcategory'     = ' ' # Request subcategory
        'urgency'         = 'Medium' # Request urgency
        'priority'        = ' ' # Request priority
        'Status'          = 'Open' # Request status
        'group'           = ' ' # Request assignment group
        'requesttype'     = 'Incident' # Request type
        'technician'      = ' ' # Request assignment technician
        'subject'         = 'GitHub Workflow Notification' # Request subject, this is appended to the incident subject
        'description'     = "A critical error was encountered during processing:  " # Request description, this prepends the incident description
    }
}