# Script that looks up all azure resources in your defined subscription that must have your defined tag name/value's. 
# Warning: Make sure these tags are only on virtual machine resource types and nothing else. The $StartStop variable must be set to true for this to work as well.

workflow startstop_by_multiple_tags
{
    Param(

        [Parameter(Mandatory=$true)]
        [String]
        $TagName1,

        [Parameter(Mandatory=$true)]
        [String]
        $TagValue1,

        [Parameter(Mandatory=$true)]
        [String]
        $TagName2,

        [Parameter(Mandatory=$true)]
        [String]
        $TagValue2,

        [Parameter(Mandatory=$true)]
        [Boolean]
        $StartStop
        )

    # Authentication piece and scope.
    "Logging in to Azure..."
    Disable-AzContextAutosave -Scope Process
    Connect-AzAccount -Identity
    $AzureContext = Set-AzContext -SubscriptionId ‘’

    # Sets the above tag name/value variables in a hashtable, that you want to filter on
$tags = @{
    $TagName1 = $TagValue1
    $TagName2 = $TagValue2
}

    # Get's all azure resources that must contain both tags and values as defined previously.
    $VMs = Get-AzResource -Tag $tags | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"} | Where-Object {$_.Tags.Keys -contains $TagName1 -and $_.Tags.Values -contains $TagValue1 -and $_.Tags.Keys -contains $TagName2 -and $_.Tags.Values -contains $TagValue2}

    Foreach ($vm in $VMs){

        if($StartStop){

            Write-Output "Stopping/Starting $($vm.Name)";        

            Start-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName ;
            #Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
            Start-Sleep -S 2

        }

        else{

            Write-Output "Stopping/Starting $($vm.Name)";        

            Start-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }
    }
}
