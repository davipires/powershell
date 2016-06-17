Import-Module ActiveDirectory
Import-Module NTFSSecurity

$query = Get-ADUser -Filter {Enabled -eq $true} | Sort SamAccountName
$users = $query.SamAccountName
$Admin = "BUILTIN\Administrators"
$Dadmins = "DOMAIN\Domain Admins"
$Sys = "NT AUTHORITY\SYSTEM"

foreach ($user in $users) {
	$userH = Get-ADUser $user -Properties HomeDirectory
	$HDrive = $userH.HomeDirectory
	Set-NTFSOwner -Path $HDrive -Account $Admin
	Disable-NTFSAccessInheritance -Path $HDrive -RemoveInheritedAccessRules
	Get-NTFSAccess -Path $HDrive | Remove-NTFSAccess
	Add-NTFSAccess -Path $HDrive -Account PEPPERMILLCAS\$user, $Admin, $Dadmins, $Sys -AccessRights FullControl
	Write-Host -Foreground Yellow -Background Black "Changed H drive permissions for $user"
}
