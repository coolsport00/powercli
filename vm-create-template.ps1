#Specify vCenter Server, Username, Password

$vCenter = "nkc-vcenter.nkcschools.org"
$vcUser = "925114@vsphere.local"
$vcPwd = "<secretpwd>"


#Specify Number of VMs to create
$vmCount = "01", "02", "03"


#Specify the Template to use
$testTemp = "rds-mgmt-template"


#Specify Customization Specification to use
$custSpec = "win2019-domain-staticip"


#Specify Datastore to place VMs on
$ds = "vdi-vmfs01"


#ESXi host to place VMs on
$esxiHost = "nkc-vdi-esx01.nkcschools.org"


#Specify VM folder to place the new VMs in
$vmFolder = "RDS Test"


#Specify the prefix to use for the VM names and IP Address
$vmPrefix = "nkc-rds-sh"
$ipPrefix = "10.201.12."


#
#End of user input parameters
#


#Create each new VM
Write-host "
  Connecting to vCenter Server $vCenter." -Foreground green
Connect-viserver $vCenter -user $vcUser -password $vcPwd -WarningAction 0 | Out-Null

$subnet = "255.255.240.0"
$gateway = "10.201.15.254"
$dns = "10.201.1.30"
$i = 80

foreach ($n in $vmCount)
{
$vmName = $vmPrefix + $n
$ipAddress = $ipPrefix + $i

Write-host "
  Creation of VM $vmName initiated. Please wait..." -Foreground Yellow

$nicMapping = Get-OSCustomizationNicMapping $custSpec
$nicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ipAddress -SubnetMask $subnet -DefaultGateway $gateway -Dns $dns -Position 1
New-VM -Name $vmName -Template $testTemp -VMHost $esxiHost -Datastore $ds -Location $vmFolder -OSCustomizationSpec $cusSpec
Start-Sleep -Seconds 70
Start-VM -VM $vmName -Confirm:$false
Start-Sleep -Seconds 30
Get-VM -Name $vmName | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "VM-510" -Confirm:$false
$i++
}

Write-Host "  All VMs created. Verify each VM settings in vCenter." -ForegroundColor Green
