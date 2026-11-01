# يرفع ما جهّزه publish.js إلى حاوية R2، ويسأل عن مفتاح R2 في الطرفية.
# القيم تبقى في هذه العملية فقط: لا تُحفظ في ملف ولا في سجل الأوامر، والسر
# يُكتب مخفيًا. الاستعمال (من مجلد المشروع):
#   & .\tools\content\upload-r2.ps1            # الصف 5
#   & .\tools\content\upload-r2.ps1 -Grade 6
param([int]$Grade = 5)

Write-Host ''
Write-Host 'مفتاح R2 من لوحة Cloudflare: R2 > Manage API Tokens' -ForegroundColor Cyan
# رقم حساب Cloudflare (ليس سرًّا: يظهر في رابط اللوحة). Enter = حساب رزمة.
$defaultAccount = 'c17527a350297afd2c75f8081ba970c6'
$account = Read-Host "Account ID (اضغط Enter لـ $defaultAccount)"
if ([string]::IsNullOrWhiteSpace($account)) { $account = $defaultAccount }
$keyId = Read-Host 'Access Key ID'
$secretSecure = Read-Host 'Secret Access Key (مخفي)' -AsSecureString
$secret = [System.Net.NetworkCredential]::new('', $secretSecure).Password

# لا تبقى القيم ظاهرة على الشاشة بعد إدخالها.
Clear-Host

$env:R2_ACCOUNT_ID = $account.Trim()
$env:R2_ACCESS_KEY_ID = $keyId.Trim()
$env:R2_SECRET_ACCESS_KEY = $secret.Trim()
try {
    # عند الفشل لا نطلب المفتاح ثانية: نعيد المحاولة بالقيم نفسها (ما رُفع لا يُرفع ثانية).
    while ($true) {
        node tools/content/upload.js --grade $Grade
        if ($LASTEXITCODE -eq 0) {
            Write-Host ''
            Write-Host 'تم الرفع.' -ForegroundColor Green
            break
        }
        Write-Host ''
        Write-Host 'فشل الرفع (السبب أعلاه).' -ForegroundColor Red
        $again = Read-Host 'أعيد المحاولة؟ اضغط Enter، أو اكتب q للخروج'
        if ($again -eq 'q') { break }
    }
} finally {
    Remove-Item Env:R2_ACCOUNT_ID, Env:R2_ACCESS_KEY_ID, Env:R2_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
    $secret = $null
}
