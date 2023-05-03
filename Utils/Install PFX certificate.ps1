
$certfilePath = "\\shord-8711\AZArc\Wildcard 2024.pfx"
$certPassword = "3verythingsB3tt3r@RedRiver"

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFilePath, $certPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

$certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
$certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$certStore.Add($cert)
$certStore.Close()

Write-Output "Certificate installed successfully."
 

