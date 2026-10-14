#!/usr/bin/env python3
"""
Convert runetfreedom/russia-v2ray-rules-dat into Anywhere (.arrs) routing rule sets.
Supports both directions:
1. Inside Russia (Bypass censorship via foreign proxy)
2. Outside Russia (Access Russian services via Russian proxy)
"""

import os
import re
import urllib.request
from pathlib import Path

MAX_RULES_PER_SET = 100000

SOURCES = {
    # Для тех, кто внутри РФ:
    "RuBlocked": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/ru-blocked.txt",
        "desc": "Popular blocked Russian domains (antifilter-community + re:filter)",
        "type": "geosite",
    },
    "RuBlocked_Community": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/antifilter-download-community.txt",
        "desc": "Blocked popular Russian domains community list (antifilter.download)",
        "type": "geosite",
    },
    "RuBlocked_IP": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked.txt",
        "desc": "Blocked IPv4 and IPv6 CIDRs in Russia",
        "type": "surge_ip",
    },
    "RuBlocked_IP_Community": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked-community.txt",
        "desc": "Blocked community IPv4 and IPv6 CIDRs in Russia",
        "type": "surge_ip",
    },
    # Все IP-адреса России:
    "RuGeoIP": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru.txt",
        "desc": "All Russian IP subnets (GeoIP RU for access from abroad)",
        "type": "surge_ip",
    },
}

ESSENTIAL_RU_SERVICES = [
    # Государственные порталы
    "gosuslugi.ru", "gu-st.ru", "gosuslugi71.ru", "uslugi.mosreg.ru", "mos.ru", "nalog.gov.ru",
    "nalog.ru", "cbr.ru", "rosreestr.gov.ru", "rosreestr.ru", "kadastr.ru", "fssp.gov.ru",
    "gibdd.ru", "pfr.gov.ru", "sfr.gov.ru", "zakupki.gov.ru", "egrul.nalog.ru", "pravo.gov.ru",
    "emias.info", "mgfoms.ru", "kremlin.ru", "government.ru", "duma.gov.ru", "council.gov.ru",
    
    # Банки и финансовые сервисы
    "sberbank.ru", "sber.ru", "sberbank.com", "tbank.ru", "tinkoff.ru", "vtb.ru", "alfabank.ru",
    "gazprombank.ru", "raiffeisen.ru", "rshb.ru", "rosbank.ru", "psbank.ru", "sovcombank.ru",
    "open.ru", "mkb.ru", "pochtabank.ru", "nspk.ru", "mironline.ru", "sbp.nspk.ru", "unicredit.ru",
    "bspb.ru", "domrfbank.ru", "otpbank.ru", "rencredit.ru", "ozon.ru", "bank.yandex.ru",

    # Транспорт
    "rzd.ru", "rzd-bonus.ru", "pass.rzd.ru", "ticket.rzd.ru", "dzvr.ru", "pochta.ru",
    "russianpost.ru", "aeroflot.ru", "s7.ru", "pobeda.aero", "utair.ru", "uralairlines.ru",
    "dme.ru", "svo.aero", "avtodor-tr.ru",

    # ТВ, Стриминги, Кино (блокирующие доступ из-за рубежа)
    "kinopoisk.ru", "hd.kinopoisk.ru", "ivi.ru", "okko.tv", "okko.sport", "premier.one",
    "wink.ru", "smotrim.ru", "1tv.ru", "ctc.ru", "tnt-online.ru", "ntv.ru", "rutube.ru",
    "kion.ru", "start.ru", "amediateka.ru", "more.tv", "matchtv.ru",

    # Сервисы с геоблоком или капчей
    "avito.ru", "hh.ru", "auto.ru", "cian.ru", "domclick.ru", "wildberries.ru", "wb.ru",
    "megamarket.ru", "samokat.ru", "dzen.ru", "yandex.ru", "yandex.net", "ya.ru", "yastatic.net"
]


def fetch_text(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "Anywhere-RuleSet-Builder/1.0"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read().decode("utf-8", errors="replace")


def parse_geosite(text: str) -> list[str]:
    domains = set()
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        if "#" in line:
            line = line.split("#", 1)[0].strip()
        
        match = re.match(r"^(?:domain|full):([a-zA-Z0-9._-]+)$", line)
        if match:
            d = match.group(1).lower().strip(".")
            if d and "*" not in d:
                domains.add(d)
        elif re.match(r"^[a-zA-Z0-9._-]+$", line):
            d = line.lower().strip(".")
            if d and "*" not in d:
                domains.add(d)
    return sorted(domains)


def parse_surge_ip(text: str) -> list[str]:
    rules = []
    seen = set()
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) >= 2:
            rule_type = parts[0].upper()
            cidr = parts[1]
            if cidr in seen:
                continue
            seen.add(cidr)
            if rule_type == "IP-CIDR":
                rules.append(f"0, {cidr}")
            elif rule_type == "IP-CIDR6":
                rules.append(f"1, {cidr}")
    return rules


def write_arrs(output_path: Path, name: str, desc: str, rules: list[str], source_url: str = "", routing: int | None = None):
    output_path.parent.mkdir(parents=True, exist_ok=True)
    header = [
        f"# NAME: {name}",
        "# GENERATED-FOR: Anywhere Routing Rule Set",
        f"# DESCRIPTION: {desc}",
        f"# RULES: {len(rules)}",
    ]
    if source_url:
        header.append(f"# SOURCE: {source_url}")
    header.append("")
    header.append(f"name = {name}")
    if routing is not None:
        header.append(f"routing = {routing}")
    
    content = "\n".join(header + rules) + "\n"
    output_path.write_text(content, encoding="utf-8")
    print(f"-> Generated {output_path.name} ({len(rules)} rules)")


def build_ru_services(output_dir: Path):
    urls = [
        "https://raw.githubusercontent.com/runetfreedom/russia-domains-list/main/ru-available-only-inside",
        "https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-gov-ru",
    ]
    domains = set(ESSENTIAL_RU_SERVICES)
    for u in urls:
        text = fetch_text(u)
        for d in parse_geosite(text):
            domains.add(d)

    sorted_domains = sorted(domains)
    rules = [f"2, {d}" for d in sorted_domains]
    
    # 1. RuServices (без routing, чтобы за границей направлять в RU Proxy)
    write_arrs(
        output_path=output_dir / "RuServices.arrs",
        name="RuServices",
        desc="Russian services with geo-restrictions (Gosuslugi, Banks, Streaming, RZD -> assign to RU Proxy)",
        rules=rules,
        source_url=" + ".join(urls),
    )
    
    # 2. RuInside (с routing = 1, для тех, кто внутри РФ)
    write_arrs(
        output_path=output_dir / "RuInside.arrs",
        name="RuInside",
        desc="Russian domestic services & government portals (Direct connection for inside RU)",
        rules=rules,
        source_url=" + ".join(urls),
        routing=1,
    )

    # 3. RuAll (Все домены зон .ru, .рф, .su + сервисы РФ)
    all_domains = set(sorted_domains)
    all_domains.add("ru")
    all_domains.add("xn--p1ai")
    all_domains.add("su")
    all_domains.update([
        "vk.com", "vk-cdn.net", "userapi.com", "ok.ru", "mail.ru", "my.games",
        "premier.one", "okko.tv", "amediateka.ru", "ozonusercontent.com", "wb.ru"
    ])
    sorted_all = sorted(all_domains)
    rules_all = [f"2, {d}" for d in sorted_all]
    write_arrs(
        output_path=output_dir / "RuAll.arrs",
        name="RuAll",
        desc="All Russian TLDs (.ru, .рф, .su) and services (assign to RU Proxy)",
        rules=rules_all,
        source_url="All RU zones + services",
    )


def main():
    out_dir = Path(__file__).parent
    print(f"Output directory: {out_dir.resolve()}")
    
    for name, meta in SOURCES.items():
        print(f"Fetching {name}...")
        text = fetch_text(meta["url"])
        if meta["type"] == "geosite":
            items = parse_geosite(text)
            rules = [f"2, {d}" for d in items]
        else:
            rules = parse_surge_ip(text)
        
        if len(rules) <= MAX_RULES_PER_SET:
            write_arrs(out_dir / f"{name}.arrs", name, meta["desc"], rules, meta["url"])
        else:
            for idx in range(0, len(rules), MAX_RULES_PER_SET):
                part = (idx // MAX_RULES_PER_SET) + 1
                part_rules = rules[idx:idx + MAX_RULES_PER_SET]
                part_name = f"{name}_{part:02d}"
                write_arrs(out_dir / f"{part_name}.arrs", part_name, f"{meta['desc']} (Part {part})", part_rules, meta["url"])

    build_ru_services(out_dir)
    print("Done!")


if __name__ == "__main__":
    main()
