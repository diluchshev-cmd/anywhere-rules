$ErrorActionPreference = "Stop"
$repoDir = "C:\Users\Work2\.gemini\antigravity\scratch\anywhere-rules"

# 1. RuServices.arrs
Write-Host "Building RuServices.arrs..."
$urls = @(
    "https://raw.githubusercontent.com/runetfreedom/russia-domains-list/main/ru-available-only-inside",
    "https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-gov-ru"
)
$domains = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($u in $urls) {
    $raw = (Invoke-WebRequest -Uri $u -UseBasicParsing).Content -split "`r?`n"
    foreach ($line in $raw) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith("#") -or $t.StartsWith("//") -or $t.StartsWith("include:")) { continue }
        if ($t -match '^([^#]+)#') { $t = $matches[1].Trim() }
        if ($t -match '^(?:domain|full):([a-z0-9._-]+)$') {
            $d = $matches[1].ToLower().Trim('.')
            if ($d -and -not $d.Contains("*")) { [void]$domains.Add($d) }
        } elseif ($t -match '^[a-z0-9._-]+$') {
            $d = $t.ToLower().Trim('.')
            if ($d -and -not $d.Contains("*")) { [void]$domains.Add($d) }
        }
    }
}

$essentialServices = @(
    # Госуслуги и госорганы
    "gosuslugi.ru", "gu-st.ru", "gosuslugi71.ru", "uslugi.mosreg.ru", "mos.ru", "nalog.gov.ru",
    "nalog.ru", "cbr.ru", "rosreestr.gov.ru", "rosreestr.ru", "kadastr.ru", "fssp.gov.ru",
    "gibdd.ru", "pfr.gov.ru", "sfr.gov.ru", "zakupki.gov.ru", "egrul.nalog.ru", "pravo.gov.ru",
    "emias.info", "mgfoms.ru", "kremlin.ru", "government.ru", "duma.gov.ru", "council.gov.ru",
    
    # Банки и платежные системы
    "sberbank.ru", "sber.ru", "sberbank.com", "tbank.ru", "tinkoff.ru", "vtb.ru", "alfabank.ru",
    "gazprombank.ru", "raiffeisen.ru", "rshb.ru", "rosbank.ru", "psbank.ru", "sovcombank.ru",
    "open.ru", "mkb.ru", "pochtabank.ru", "nspk.ru", "mironline.ru", "sbp.nspk.ru", "unicredit.ru",
    "bspb.ru", "domrfbank.ru", "otpbank.ru", "rencredit.ru", "ozon.ru", "bank.yandex.ru",

    # Транспорт
    "rzd.ru", "rzd-bonus.ru", "pass.rzd.ru", "ticket.rzd.ru", "dzvr.ru", "pochta.ru",
    "russianpost.ru", "aeroflot.ru", "s7.ru", "pobeda.aero", "utair.ru", "uralairlines.ru",
    "dme.ru", "svo.aero", "avtodor-tr.ru",

    # ТВ, Стриминги, Кино (блокирующие зарубежные IP)
    "kinopoisk.ru", "hd.kinopoisk.ru", "ivi.ru", "okko.tv", "okko.sport", "premier.one",
    "wink.ru", "smotrim.ru", "1tv.ru", "ctc.ru", "tnt-online.ru", "ntv.ru", "rutube.ru",
    "kion.ru", "start.ru", "amediateka.ru", "more.tv", "matchtv.ru", "vestikavkaza.ru",

    # Сервисы с геоблоком или капчей
    "avito.ru", "hh.ru", "auto.ru", "cian.ru", "domclick.ru", "wildberries.ru", "wb.ru",
    "megamarket.ru", "samokat.ru", "dzen.ru", "yandex.ru", "yandex.net", "ya.ru", "yastatic.net"
)

foreach ($item in $essentialServices) { [void]$domains.Add($item) }

$sortedServices = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::OrderBy($domains, [Func[string,string]]{ param($x) $x }))
$sbServices = [System.Text.StringBuilder]::new()
[void]$sbServices.AppendLine("# NAME: RuServices")
[void]$sbServices.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
[void]$sbServices.AppendLine("# DESCRIPTION: Russian services with geo-restrictions (Gosuslugi, Banks, Streaming, RZD -> RU Proxy)")
[void]$sbServices.AppendLine("# RULES: $($sortedServices.Length)")
[void]$sbServices.AppendLine("")
[void]$sbServices.AppendLine("name = RuServices")
foreach ($d in $sortedServices) { [void]$sbServices.AppendLine("2, $d") }
[System.IO.File]::WriteAllText("$repoDir\RuServices.arrs", $sbServices.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "-> RuServices.arrs ($($sortedServices.Length) rules)"

# 2. RuAll.arrs (All RU zones + non-.ru Russian services)
Write-Host "Building RuAll.arrs..."
$allRuDomains = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
# TLDs
[void]$allRuDomains.Add("ru")
[void]$allRuDomains.Add("xn--p1ai") # .рф
[void]$allRuDomains.Add("su")
# Add all from services
foreach ($d in $sortedServices) { [void]$allRuDomains.Add($d) }
# Additional popular Russian portals on non-.ru domains
$nonRuTld = @(
    "vk.com", "vk-cdn.net", "userapi.com", "ok.ru", "mail.ru", "my.games",
    "premier.one", "okko.tv", "amediateka.ru", "ozonusercontent.com", "wb.ru"
)
foreach ($d in $nonRuTld) { [void]$allRuDomains.Add($d) }

$sortedAll = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::OrderBy($allRuDomains, [Func[string,string]]{ param($x) $x }))
$sbAll = [System.Text.StringBuilder]::new()
[void]$sbAll.AppendLine("# NAME: RuAll")
[void]$sbAll.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
[void]$sbAll.AppendLine("# DESCRIPTION: All Russian TLDs (.ru, .рф, .su) and services for access via RU Proxy")
[void]$sbAll.AppendLine("# RULES: $($sortedAll.Length)")
[void]$sbAll.AppendLine("")
[void]$sbAll.AppendLine("name = RuAll")
foreach ($d in $sortedAll) { [void]$sbAll.AppendLine("2, $d") }
[System.IO.File]::WriteAllText("$repoDir\RuAll.arrs", $sbAll.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "-> RuAll.arrs ($($sortedAll.Length) rules)"

# 3. RuGeoIP.arrs
Write-Host "Building RuGeoIP.arrs..."
$ipUrl = "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru.txt"
$rawIp = (Invoke-WebRequest -Uri $ipUrl -UseBasicParsing).Content -split "`r?`n"
$ipRules = [System.Collections.Generic.List[string]]::new()
$seenIp = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($line in $rawIp) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith("#") -or $t.StartsWith("//")) { continue }
    $parts = $t -split ","
    if ($parts.Length -ge 2) {
        $type = $parts[0].Trim().ToUpper()
        $cidr = $parts[1].Trim()
        if ($cidr -and -not $seenIp.Contains($cidr)) {
            [void]$seenIp.Add($cidr)
            if ($type -eq "IP-CIDR") {
                $ipRules.Add("0, $cidr")
            } elseif ($type -eq "IP-CIDR6") {
                $ipRules.Add("1, $cidr")
            }
        }
    }
}
$sbIp = [System.Text.StringBuilder]::new()
[void]$sbIp.AppendLine("# NAME: RuGeoIP")
[void]$sbIp.AppendLine("# GENERATED-FOR: Anywhere Routing Rule Set")
[void]$sbIp.AppendLine("# DESCRIPTION: All Russian IP subnets (GeoIP RU -> RU Proxy)")
[void]$sbIp.AppendLine("# RULES: $($ipRules.Count)")
[void]$sbIp.AppendLine("# SOURCES:")
[void]$sbIp.AppendLine("# - $ipUrl")
[void]$sbIp.AppendLine("")
[void]$sbIp.AppendLine("name = RuGeoIP")
foreach ($r in $ipRules) { [void]$sbIp.AppendLine($r) }
[System.IO.File]::WriteAllText("$repoDir\RuGeoIP.arrs", $sbIp.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "-> RuGeoIP.arrs ($($ipRules.Count) rules)"
