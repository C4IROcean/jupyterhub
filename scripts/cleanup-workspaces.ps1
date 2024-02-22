# The script identifies the PVC resources by the user names listed in obsolete-workspaces file and after confirmation deletes them. 
# The associated persistent volume and storage will then be removed by Azure automatically.
# Then the users from obsolete-workspaces file are also removed from JupyterHub if confirmed.

$namespace = "daskhub"
$textFilePath = "obsolete-workspaces"

#Read .env variables
get-content .env | ForEach-Object {
    $name, $value = $_.split('=')
    set-content env:\$name $value
}

# Read the text file
$users = Get-Content -Path $textFilePath
$pvcNames = @()
Write-Host "Identifying PVC names from namespace $namespace"

foreach ($user in $users) {
    $pvcName = kubectl get pvc -n $namespace -o json | ConvertFrom-Json | ForEach-Object { $_.items } | Where-Object { $_.metadata.annotations.'hub.jupyter.org/username' -eq $user } | ForEach-Object { $_.metadata.name }
    Write-Host ("User $user has PVC $pvcName")
    if ($pvcName) { $pvcNames += $pvcName }
}
 # Display the PVC names and ask for confirmation
 Write-Host "The above PVC resources are to be deleted from namespace $namespace."
 $confirmation = Read-Host "Are you sure you want to delete these PVCs? (yes/no)"
 
 # Delete the PVCs if the user confirmed
 if ($confirmation -eq "yes") {
     foreach ($pvcName in $pvcNames) {
         kubectl delete pvc $pvcName -n $namespace
     }  
 }

 $confirmation = Read-Host "Are you sure you want to delete the users from JupyterHub? (yes/no)"
 
 # Call the Delete API for the users if confirmed
 if ($confirmation -eq "yes") {
    foreach ($user in $users) {
        $headers = @{
           "Authorization" = "token $env:JUPYTER_HUB_TOKEN"
       }
       $apiUrl = "https://workspace.hubocean.earth/hub/api/users/$user"
       Write-Host "Deleting $user workspace..."
       Invoke-RestMethod -Uri $apiUrl -Method Delete -Headers $headers
    }
 }