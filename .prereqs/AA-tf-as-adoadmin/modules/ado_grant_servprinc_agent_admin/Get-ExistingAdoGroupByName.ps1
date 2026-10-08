# LLM-authored.  Haven't deeply proofread.  10/8/26, 8:54 AM.
$ErrorActionPreference = 'Stop'
$query = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction 'Stop'
$desiredGroupName = [string]$query.desired_group_name
$scope = [string]$query.scope
$organizationUrl = [string]$query.organization_url
$projectName = [string]$query.project_name

if ([string]::IsNullOrWhiteSpace($desiredGroupName)) {
    throw 'desired_group_name must be provided in the external data source query.'
}
if ($scope -notin @('organization', 'project')) {
    throw "scope must be 'organization' or 'project'; received '$scope'."
}
if ([string]::IsNullOrWhiteSpace($organizationUrl)) {
    throw 'organization_url must be provided in the external data source query.'
}
if ($scope -eq 'project' -and [string]::IsNullOrWhiteSpace($projectName)) {
    throw 'project_name is required when scope is project.'
}

$groups = [System.Collections.Generic.List[object]]::new()
$continuationToken = $null

do {
    $azArgs = @(
        'devops', 'security', 'group', 'list',
        '--scope', $scope,
        '--organization', $organizationUrl,
        '--subject-types', 'vssgp',
        '--output', 'json'
    )
    if ($scope -eq 'project') {
        $azArgs += @('--project', $projectName)
    }
    if ($continuationToken) {
        $azArgs += @('--continuation-token', $continuationToken)
    }

    $pageJson = & az @azArgs
    if ($LASTEXITCODE -ne 0) {
        throw "az devops security group list failed with exit code $LASTEXITCODE."
    }

    $page = ConvertFrom-Json -InputObject ($pageJson -join "`n") -ErrorAction Stop
    foreach ($group in $page.graphGroups) {
        $groups.Add($group)
    }

    $tokenValue = $page.continuationToken
    if ($tokenValue -is [array]) {
        $continuationToken = [string]$tokenValue[0]
    }
    else {
        $continuationToken = [string]$tokenValue
    }
} while (-not [string]::IsNullOrWhiteSpace($continuationToken))

$foundGroups = @($groups | Where-Object { $_.displayName -eq $desiredGroupName })
if ($foundGroups.Count -gt 1) {
    throw "Found multiple groups named '$desiredGroupName' in scope '$scope'."
}

$resolvedGroup = if ($foundGroups.Count -eq 1) { $foundGroups[0] } else { $null }
[ordered]@{
    exists     = if ($resolvedGroup) { 'true' } else { 'false' }
    id         = if ($resolvedGroup) { [string]$resolvedGroup.originId } else { '' }
    descriptor = if ($resolvedGroup) { [string]$resolvedGroup.descriptor } else { '' }
} | ConvertTo-Json -Compress