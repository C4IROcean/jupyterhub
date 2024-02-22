# Prerequisite:
 [Generate a token](https://workspace.hubocean.earth/hub/token) and place it into the .env file. Do not add your token to the source control!

# api.http
The file can be used to execute Jupyter API calls using the [VSCode Extension REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)

# cleanup-workspaces.ps1
The powershell script can be used to delete workspaces based on the user names stored in the `obsolete-workspaces` file.

**Steps executed:**
- persistent volume claims are identified based on the user name and listed
- on confirmation all identified PVCs will be deleted
- on confirmation all users are removed from the JupyterHub by executing REST calls