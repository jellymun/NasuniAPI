#requires -version 3
<#
.SYNOPSIS
  Inital Connection and Query of the Nasuni NMC API
.DESCRIPTION
  Extract Volumes, Filers & Shares
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  Tested against NasuniNMc 8.0.3
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\scripts"
$sLogName = "Nasuni_settings_QR.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#Nasuni NMC Server
$nasuninmc='NMCName'
#Inital Logon to get Token
$parameters = @{username = "adminadmin";
  password = "adminpassword";} 

CD "C:\Scripts"


#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here


[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null


  try
{
    $AuthResponse = Invoke-RestMethod -body  $parameters  -uri "https://$nasuninmc/api/v1.1/auth/login/" -Method Post -Verbose
    $AuthResponse
}

catch
{
    $_.Exception | Format-List -Force
}


#CreateTheToken
$TokenX = @{Authorization = "token $($AuthResponse.token)"} 

#Listvolumes

$volumes=@()
$whyme=$false
try
{
   DO {
    #needed loop thru just incase, need a better way :)
    If ($whyme -ne $false){
        $Grab=Invoke-RestMethod  -uri $whyme -Headers $TokenX}else{$Grab=Invoke-RestMethod  -uri "https://$nasuninmc/api/v1.1/volumes/" -Headers $TokenX}
    If ($Grab.next){$whyme=$Grab.next}else{$whyme=$false}
    $volumes+=$Grab.items    
    } Until ($whyme -eq $false)
}
catch
{
 $_.Exception | Format-List -Force
}


#Listfilers

$filers=@()
$whyme=$false
try
{
   DO {
    #needed loop thru just incase, need a better way :)
    If ($whyme -ne $false){
        $Grab=Invoke-RestMethod  -uri $whyme -Headers $TokenX}else{$Grab=Invoke-RestMethod  -uri "https://$nasuninmc/api/v1.1/filers/" -Headers $TokenX}
    If ($Grab.next){$whyme=$Grab.next}else{$whyme=$false}
    $filers+=$Grab.items    
    } Until ($whyme -eq $false)
}
catch
{
 $_.Exception | Format-List -Force
}

#ListShares

$shares=@()
$whyme=$false
try
{
   DO {
    #needed loop thru just incase, need a better way :)
    If ($whyme -ne $false){
        $Grab=Invoke-RestMethod  -uri $whyme -Headers $TokenX}else{$Grab=Invoke-RestMethod  -uri "https://$nasuninmc/api/v1.1/volumes/filers/shares/" -Headers $TokenX}
    If ($Grab.next){$whyme=$Grab.next}else{$whyme=$false}
    $shares+=$Grab.items    
    } Until ($whyme -eq $false)
}
catch
{
 $_.Exception | Format-List -Force
}

#
# Start your reporting here..
#funtimes

write-host Volumes: $volumes.Count
write-host Filers : $filers.count
write-host Shares : $shares.Count

# 
#
#Log-Finish -LogPath $sLogFile
