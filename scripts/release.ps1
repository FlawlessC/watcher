[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$ErrorActionPreference = "Stop"

Write-Host "=== Watcher Release Script ===" -ForegroundColor Cyan

# Read pubspec version
$pubspecPath = "pubspec.yaml"
$versionJsonPath = "version.json"

$pubspec = Get-Content $pubspecPath -Raw

if ($pubspec -notmatch "version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)") {
    throw "Could not find version in pubspec.yaml"
}

$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$build = [int]$Matches[4]

$releaseType = Read-Host "Release type: patch / minor / major"

$newBuild = $build + 1

switch ($releaseType) {
    "major" {
        $major = $major + 1
        $minor = 0
        $patch = 0
    }
    "minor" {
        $minor = $minor + 1
        $patch = 0
    }
    "patch" {
        $patch = $patch + 1
    }
    default {
        throw "Unknown release type. Use: patch, minor, or major"
    }
}

$newVersion = "$major.$minor.$patch"
$newFullVersion = "$newVersion+$newBuild"
$newTag = "v$newVersion"

Write-Host "Current: $major.$minor.$patch+$build"
Write-Host "New:     $newFullVersion"
Write-Host "Tag:     $newTag" -ForegroundColor Green

$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled"
    exit
}

$changelogInput = Read-Host "App changelog. Use \n for new lines"
$changelog = $changelogInput -replace "\\n", "`n"

if ([string]::IsNullOrWhiteSpace($changelog)) {
    $changelog = "App improvements and fixes"
}

# Update pubspec.yaml
$pubspec = $pubspec -replace "version:\s+\d+\.\d+\.\d+\+\d+", "version: $newFullVersion"
Set-Content $pubspecPath $pubspec -Encoding UTF8

# Update version.json
$versionData = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
$versionData.version = $newVersion
$versionData.build = $newBuild
$versionData.apk_url = "https://github.com/FlawlessC/watcher/releases/download/$newTag/app-release.apk"
$versionData.changelog = $changelog

$versionData | ConvertTo-Json -Depth 10 | Set-Content $versionJsonPath -Encoding UTF8

# Create release notes for GitHub Release
$releaseNotes = @"
## Watcher $newVersion

$changelog

### Changes
- Android APK updated
- Web version deployed
- App version bumped to $newFullVersion
"@

Set-Content "RELEASE_NOTES.md" $releaseNotes -Encoding UTF8

Write-Host "Running flutter analyze..." -ForegroundColor Cyan
flutter analyze

Write-Host "Git commit and push..." -ForegroundColor Cyan
git add .
git commit -m "Release $newVersion"
git push

Write-Host "Creating tag..." -ForegroundColor Cyan
git tag $newTag
git push origin $newTag

Write-Host "Done! Check GitHub Actions." -ForegroundColor Green