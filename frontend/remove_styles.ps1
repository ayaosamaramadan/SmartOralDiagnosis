$files = @(
    "c:\Users\YOYO\SmartOralDiagnosis\frontend\src\app\register\page.tsx",
    "c:\Users\YOYO\SmartOralDiagnosis\frontend\src\app\admin\dashboard\page.tsx",
    "c:\Users\YOYO\SmartOralDiagnosis\frontend\src\app\doctor\dashboard\page.tsx",
    "c:\Users\YOYO\SmartOralDiagnosis\frontend\src\app\patient\dashboard\page.tsx"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processing $file..."
        $content = Get-Content $file -Raw
        $content = $content -replace 'className="[^"]*"', ''
        $content = $content -replace 'className=""', ''
        Set-Content $file $content
        Write-Host "Completed $file"
    }
}

Write-Host "All styles removed!"
