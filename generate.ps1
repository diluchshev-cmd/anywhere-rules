$ErrorActionPreference = "Stop"
$outDir = "C:\Users\Work2\.gemini\antigravity\scratch\anywhere-rules"

function Convert-Geosite {
    param([string]$Url, [string]$Name, [string]$Desc, [string]$OutPath, [int]$Routing = $null)
    Write-Host "Converting Geosite: $Name"
    $raw = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content -split "`r?`n"
    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($line in $raw) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith("#") -or $t.StartsWith("//")) { continue }
        if ($t -match '^([^#]+)#') { $t = $matches[1].Trim() }
        if ($t -match '^(?:domain|full):([a-z0-9._-]+)$') {
            $d = $matches[1].ToLower().Trim('.')
            if ($d -and -not $d.Contains("*")) { [void]$set.Add($d) }
        } elseif ($t -match '^[a-z0-9._-]+$') {
            $d = $t.ToLower().Trim('.')
            if ($d -and -not $d.Contains("*")) { [void]$set.Add($d) }
        }
    }
    $sorted = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::OrderBy($set, [Func[string,string]]{ param($x) $x }))
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# NAME: $Name")
    [void]$sb.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
    [void]$sb.AppendLine("# DESCRIPTION: $Desc")
    [void]$sb.AppendLine("# RULES: $($sorted.Length)")
    [void]$sb.AppendLine("# SOURCES:")
    [void]$sb.AppendLine("# - $Url")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("name = $Name")
    if ($Routing -ne $null) { [void]$sb.AppendLine("routing = $Routing") }
    foreach ($d in $sorted) { [void]$sb.AppendLine("2, $d") }
    [System.IO.File]::WriteAllText($OutPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "-> $OutPath ($($sorted.Length) rules)"
}

function Convert-SurgeIP {
    param([string]$Url, [string]$Name, [string]$Desc, [string]$OutPath, [int]$Routing = $null)
    Write-Host "Converting GeoIP: $Name"
    $raw = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content -split "`r?`n"
    $rules = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($line in $raw) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith("#") -or $t.StartsWith("//")) { continue }
        $parts = $t -split ","
        if ($parts.Length -ge 2) {
            $type = $parts[0].Trim().ToUpper()
            $cidr = $parts[1].Trim()
            if ($cidr -and -not $seen.Contains($cidr)) {
                [void]$seen.Add($cidr)
                if ($type -eq "IP-CIDR") {
                    $rules.Add("0, $cidr")
                } elseif ($type -eq "IP-CIDR6") {
                    $rules.Add("1, $cidr")
                }
            }
        }
    }
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# NAME: $Name")
    [void]$sb.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
    [void]$sb.AppendLine("# DESCRIPTION: $Desc")
    [void]$sb.AppendLine("# RULES: $($rules.Count)")
    [void]$sb.AppendLine("# SOURCES:")
    [void]$sb.AppendLine("# - $Url")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("name = $Name")
    if ($Routing -ne $null) { [void]$sb.AppendLine("routing = $Routing") }
    foreach ($r in $rules) { [void]$sb.AppendLine($r) }
    [System.IO.File]::WriteAllText($OutPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "-> $OutPath ($($rules.Count) rules)"
}

function Build-RuInside {
    param([string]$OutPath)
    Write-Host "Building RuInside (Domestic / Gosuslugi / Banks -> DIRECT)"
    $urls = @(
        "https://raw.githubusercontent.com/runetfreedom/russia-domains-list/main/ru-available-only-inside",
        "https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-gov-ru"
    )
    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($u in $urls) {
        $raw = (Invoke-WebRequest -Uri $u -UseBasicParsing).Content -split "`r?`n"
        foreach ($line in $raw) {
            $t = $line.Trim()
            if (-not $t -or $t.StartsWith("#") -or $t.StartsWith("//") -or $t.StartsWith("include:")) { continue }
            if ($t -match '^([^#]+)#') { $t = $matches[1].Trim() }
            if ($t -match '^(?:domain|full):([a-z0-9._-]+)$') {
                $d = $matches[1].ToLower().Trim('.')
                if ($d -and -not $d.Contains("*")) { [void]$set.Add($d) }
            } elseif ($t -match '^[a-z0-9._-]+$') {
                $d = $t.ToLower().Trim('.')
                if ($d -and -not $d.Contains("*")) { [void]$set.Add($d) }
            }
        }
    }
    # Add common banking & government domains if not present
    $extras = @(
        "gosuslugi.ru", "mos.ru", "nalog.gov.ru", "sberbank.ru", "sber.ru",
        "tbank.ru", "tinkoff.ru", "vtb.ru", "alfabank.ru", "cbr.ru", "raiffeisen.ru",
        "gazprombank.ru", "rosbank.ru", "rshb.ru", "rzd.ru", "pochta.ru", "kinopoisk.ru", "yandex.ru"
    )
    foreach ($e in $extras) { [void]$set.Add($e) }
    
    $sorted = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::OrderBy($set, [Func[string,string]]{ param($x) $x }))
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# NAME: RuInside")
    [void]$sb.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
    [void]$sb.AppendLine("# DESCRIPTION: Russian domestic and government services (Direct connection)")
    [void]$sb.AppendLine("# RULES: $($sorted.Length)")
    [void]$sb.AppendLine("# SOURCES:")
    foreach ($u in $urls) { [void]$sb.AppendLine("# - $u") }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("name = RuInside")
    [void]$sb.AppendLine("routing = 1") # 1 = DIRECT
    foreach ($d in $sorted) { [void]$sb.AppendLine("2, $d") }
    [System.IO.File]::WriteAllText($OutPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "-> $OutPath ($($sorted.Length) rules)"
}

Convert-Geosite -Url "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/ru-blocked.txt" `
                -Name "RuBlocked" `
                -Desc "Blocked Russian domains (antifilter-community + re:filter)" `
                -OutPath "$outDir\RuBlocked.arrs"

Convert-Geosite -Url "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/antifilter-download-community.txt" `
                -Name "RuBlocked_Community" `
                -Desc "Blocked popular Russian domains community list" `
                -OutPath "$outDir\RuBlocked_Community.arrs"

Convert-SurgeIP -Url "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked.txt" `
                -Name "RuBlocked_IP" `
                -Desc "Blocked IP CIDRs in Russia" `
                -OutPath "$outDir\RuBlocked_IP.arrs"

Convert-SurgeIP -Url "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked-community.txt" `
                -Name "RuBlocked_IP_Community" `
                -Desc "Blocked community IP CIDRs in Russia" `
                -OutPath "$outDir\RuBlocked_IP_Community.arrs"

Build-RuInside -OutPath "$outDir\RuInside.arrs"
