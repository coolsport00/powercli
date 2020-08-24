#Specify vCenter Server, Username, Password

$vCenter = "nkc-vcenter.domain"
$vcUser = "925114@vsphere.local"
$vcPwd = "<secretpwd>"


#ESXi hosts to place VMs on
$esxiHost1 = "nkc-vdi-esx01.domain"
$esxiHost2 = "nkc-vdi-esx02.domain"
$esxiHost3 = "nkc-vdi-esx03.domain"


#Specify the Template to use
$vmTemplate = "rds-sh-postapp-template"


#Specify Customization Specification to use
$custSpec = "win2019-domain-staticip"


#Specify Datastore to place VMs on
$ds = "vdi-vmfs01"


#Specify VM folder to place the new VMs in
$vmFolder = "RDS Session Hosts"


#Specify the prefix to use for the VM names and IP Address
$vmPrefix = "nkc-rds-sh"
$ipPrefix = "10.201.3."


#
#End of user input parameters
#


#Create each new VM
Write-host "
  Connecting to vCenter Server $vCenter." -Foreground green
Connect-viserver $vCenter -user $vcUser -password $vcPwd -WarningAction 0 | Out-Null

$subnet = "255.255.240.0"
$gateway = "10.201.15.254"
$pdns = "10.201.1.30"
$sdns = "10.201.1.31"

$ans = Read-Host "
  Specify which ESXi Host wanting to add VMs to (1, 2, or 3):
  1 = vdi-esx01 (rds-sh01-sh05)
  2 = vdi-esx02 (rds-sh06-sh10)
  3 = vid-esx03 (rds-sh11-sh15) "

If ($ans -eq 1)
{
  #Specify Number of VMs to create
  $vmCount1 = 5
  $i = 60
  1..$vmCount1 | foreach {
    $n1 = "{0:D2}" -f + $_
      $vmName1 = $vmPrefix + $n1
    $ipAddress = $ipPrefix + $i

    Write-host "
  Creation of VM $vmName1 initiated. Please wait..." -Foreground Yellow

    $nicMapping = Get-OSCustomizationSpec $custSpec | Get-OSCustomizationNicMapping
    $nicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ipAddress -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns -Position 1
    New-VM -Name $vmName1 -Template $vmTemplate -VMHost $esxiHost1 -Datastore $ds -Location $vmFolder | Set-VM -OSCustomizationSpec $custSpec -Confirm:$false

    Start-VM -VM $vmName1 -Confirm:$false
    Start-Sleep -Seconds 8
    Get-VM -Name $vmName1 | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "VM-510" -Connected:$false -Confirm:$false
    Get-VM -Name $vmName1 | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false
    $i++
    }
}
ElseIf ($ans -eq 2)
{
  #Specify Number of VMs to create
  $vmCount2 = 10
  $i = 65
  6..$vmCount2 | foreach {
    $n2 = "{0:D2}" -f + $_
    $vmName2 = $vmPrefix + $n2
    $ipAddress = $ipPrefix + $i

    Write-host "
  Creation of VM $vmName2 initiated. Please wait..." -Foreground Yellow

    $nicMapping = Get-OSCustomizationSpec $custSpec | Get-OSCustomizationNicMapping
    $nicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ipAddress -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns -Position 1
    New-VM -Name $vmName2 -Template $vmTemplate -VMHost $esxiHost2 -Datastore $ds -Location $vmFolder | Set-VM -OSCustomizationSpec $custSpec -Confirm:$false

    Start-VM -VM $vmName2 -Confirm:$false
    Start-Sleep -Seconds 8
    Get-VM -Name $vmName2 | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "VM-510" -Connected:$false -Confirm:$false
    Get-VM -Name $vmName2 | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false
    $i++
    }
}
ElseIf ($ans -eq 3)
{
  #Specify Number of VMs to create
  $vmCount3 = 15
  $i = 70
  11..$vmCount3 | foreach {
    $n3 = "{0:D2}" -f + $_
    $vmName3 = $vmPrefix + $n3
    $ipAddress = $ipPrefix + $i

    Write-host "
  Creation of VM $vmName3 initiated. Please wait..." -Foreground Yellow

    $nicMapping = Get-OSCustomizationSpec $custSpec | Get-OSCustomizationNicMapping
    $nicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ipAddress -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns -Position 1
    New-VM -Name $vmName3 -Template $vmTemplate -VMHost $esxiHost3 -Datastore $ds -Location $vmFolder | Set-VM -OSCustomizationSpec $custSpec -Confirm:$false

    Start-VM -VM $vmName3 -Confirm:$false
    Start-Sleep -Seconds 8
    Get-VM -Name $vmName3 | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "VM-510" -Connected:$false -Confirm:$false
    Get-VM -Name $vmName3 | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false
    $i++
    }
}
Else
{
Write-Host "
  You did not select 1, 2, or 3. Hit CTL+C and re-run the script."  -ForegroundColor DarkRed
}


Write-Host "
  All VMs for specified VDI Host have been created. It can take several minutes for the VMs to be
  added to Active Directory. Verify each VM settings in AD and vCenter." -ForegroundColor Green
Write-Host "
  If it takes more than 7mins or so for VM to be added to AD, check the VM nic (disconnect/reconnect)."  -ForegroundColor Green
Write-Host "
  Re-run the script for each remaining VDI Host VM creation." -ForegroundColor Yellow



