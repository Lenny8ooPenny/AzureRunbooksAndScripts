#Must first register a new app with the right graph permissions 'Mail.Send' and must generate a secret key. See: https://adamtheautomator.com/azure-send-email/#Using_Microsoft_Graph_API_to_Send_Azure_Email

# replace with your application ID
$client_id = ''

# replace with your secret key
$client_secret = ''

# replace with your tenant ID
$tenant_id = ''

# DO NOT CHANGE ANYTHING BELOW THIS LINE
$request = @{
        Method = 'POST'
        URI    = "https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token"
        body   = @{
            grant_type    = "client_credentials"
            scope         = "https://graph.microsoft.com/.default"
            client_id     = $client_id
            client_secret = $client_secret
        }
    }
    
# Get the access token
$token = (Invoke-RestMethod @request).access_token

# view the token value
$token

# Provide the sender and recipient email address
$fromAddress = ''
$toAddress = ''

# Specify the email subject and the message
$mailSubject = 'This is a test message from Azure via Microsoft Graph API'
$mailMessage = 'Test Message || Azure via Microsoft Graph API'

# DO NOT CHANGE ANYTHING BELOW THIS LINE
# Build the Microsoft Graph API request
$params = @{
  "URI"         = "https://graph.microsoft.com/v1.0/users/$fromAddress/sendMail"
  "Headers"     = @{
    "Authorization" = ("Bearer {0}" -F $token)
  }
  "Method"      = "POST"
  "ContentType" = 'application/json'
  "Body" = (@{
    "message" = @{
      "subject" = $mailSubject
      "body"    = @{
        "contentType" = 'Text'
        "content"     = $mailMessage
      }
      "toRecipients" = @(
        @{
          "emailAddress" = @{
            "address" = $toAddress
          }
        }
      )
    }
  }) | ConvertTo-JSON -Depth 10
}

# Send the message
Invoke-RestMethod @params -Verbose
