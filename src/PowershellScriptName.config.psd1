@{
    'MicrosoftGraph'    = @{ # Example of a Microsoft Graph configuration
        'ClientId' = ' ' # Application ID
        'TenantId' = ' ' # Tenant ID
        'Scope'    = @("Directory.Read.All", "User.Read.All") # Required scopes for operations, customize as needed
    }
    'MessageParameters' = @{
        # This section configures the email alert failback if service now is not available
        'To'          = ' ' # Recipient email address
        'From'        = " " # Sender email address
        'Body'        = "A critical error was encountered during processing:<br><br>A total of [{0}] errors were logged.  Please view logs for details.<br>The process is executed via the script {1} on {2}.<br> Error and Github Workflow run details can be found at {3}.<br>" # Email body
        'Subject'     = " " # Email subject
        'SMTPServer'  = ' ' # SMTP server
        'Priority'    = 'High' # Email priority
        'BodyAsHTML'  = $True # Email body is HTML
        'ErrorAction' = 'Stop' # Action to take on error
    }
    'ManageEngine'      = @{ # Example of a ManageEngine configuration
        'clientScope'     = 'SDPOnDemand.requests.ALL' # Client scope
        'oauthUrl'        = 'https://accounts.zoho.com/oauth/v2/token' # OAuth URL
        'manageengineUri' = 'https://sdpondemand.manageengine.com/app/itdesk/api/v3/requests' # ManageEngine URI
        'ErrorTicket'     = @{
            'requester'   = '' # Requester email address
            'category'    = '' # Category
            'impact'      = '' # Impact
            'subcategory' = '' # Subcategory
            'urgency'     = '' # Urgency
            'priority'    = '' # Priority
            'Status'      = 'Open' # Status
            'group'       = ''    # Group
            'technician'  = '' # Technician email address
            'requesttype' = 'Incident' # Request type
            'subject'     = 'GitHub Workflow Notification' # Subject
            'description' = "A critical error was encountered during processing:<br><br>A total of [{0}] errors were logged.  Please view logs for details.<br>The process is executed via the script {1} on {2}.<br> Error and Github Workflow run details can be found at {3}.<br>" # Description
            
        }
        'SuccessTicket'   = @{
            'Requester'       = '' # Requester email address
            'Category'        = '' # Category
            'Impact'          = '' # Impact
            'Subcategory'     = '' # Subcategory
            'Urgency'         = '' # Urgency
            'Priority'        = '' # Priority
            'Status'          = 'Closed' # Status
            'technician'      = '' # Technician email address
            'RequestType'     = 'Incident' # Request type
            'Subject'         = 'AUTOMATION SUCCEEDED' # Subject
            'Description'     = 'AUTOMATION SUCCEEDED. <br>The process is executed via the script {0} on {1}.<br> Logs and Github Workflow run details can be found at {2}.<br>"' # Description
        }
    }
}