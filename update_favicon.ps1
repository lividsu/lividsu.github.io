Get-ChildItem -Path . -Filter "*.html" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace 'href="https://lividsu.com/favicon.ico"', 'href="favicon.ico"'
    $content = $content -replace 'href="http://lividsu.com/favicon.ico"', 'href="favicon.ico"'
    Set-Content $_.FullName $content
} 