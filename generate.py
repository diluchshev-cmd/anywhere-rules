#!/usr/bin/env python3
"""
Convert runetfreedom/russia-v2ray-rules-dat (russia-blocked-geosite & russia-blocked-geoip)
into Anywhere (.arrs) routing rule sets.
"""

import os
import re
import urllib.request
from pathlib import Path

MAX_RULES_PER_SET = 100000

SOURCES = {
    "RuBlocked": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/ru-blocked.txt",
        "desc": "Popular blocked Russian domains (antifilter-community + re:filter)",
        "type": "geosite",
        "routing": None, # Default / Proxy
    },
    "RuBlocked_Community": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geosite/release/antifilter-download-community.txt",
        "desc": "Blocked popular Russian domains community list (antifilter.download)",
        "type": "geosite",
        "routing": None, # Default / Proxy
    },
    "RuBlocked_IP": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked.txt",
        "desc": "Blocked IPv4 and IPv6 CIDRs in Russia",
        "type": "surge_ip",
        "routing": None, # Default / Proxy
    },
    "RuBlocked_IP_Community": {
        "url": "https://raw.githubusercontent.com/runetfreedom/russia-blocked-geoip/release/surge/ru-blocked-community.txt",
        "desc": "Blocked community IPv4 and IPv6 CIDRs in Russia",
        "type": "surge_ip",
        "routing": None, # Default / Proxy
    },
}

EXTRA_INSIDE_DOMAINS = [
    "gosuslugi.ru", "mos.ru", "nalog.gov.ru", "sberbank.ru", "sber.ru",
    "tbank.ru", "tinkoff.ru", "vtb.ru", "alfabank.ru", "cbr.ru", "raiffeisen.ru",
    "gazprombank.ru", "rosbank.ru", "rshb.ru", "rzd.ru", "pochta.ru",
    "kinopoisk.ru", "yandex.ru", "yandex.net", "ozon.ru", "wildberries.ru",
    "avito.ru", "vk.com", "ok.ru", "mail.ru", "dzen.ru"
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


def write_arrs(output_path: Path, name: str, desc: str, rules: list[str], source_url: str, routing: int | None = None):
    output_path.parent.mkdir(parents=True, exist_ok=True)
    header = [
        f"# NAME: {name}",
        "# GENERATED-FOR: Anywhere Routing Rule Set",
        f"# DESCRIPTION: {desc}",
        f"# RULES: {len(rules)}",
        "# SOURCES:",
        f"# - {source_url}",
        "",
        f"name = {name}",
    ]
    if routing is not None:
        header.append(f"routing = {routing}")
    
    content = "\n".join(header + rules) + "\n"
    output_path.write_text(content, encoding="utf-8")
    print(f"-> Generated {output_path.name} ({len(rules)} rules)")


def build_ru_inside(output_dir: Path):
    urls = [
        "https://raw.githubusercontent.com/runetfreedom/russia-domains-list/main/ru-available-only-inside",
        "https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-gov-ru",
    ]
    domains = set(EXTRA_INSIDE_DOMAINS)
    for u in urls:
        text = fetch_text(u)
        for d in parse_geosite(text):
            domains.add(d)

    sorted_domains = sorted(domains)
    rules = [f"2, {d}" for d in sorted_domains]
    write_arrs(
        output_path=output_dir / "RuInside.arrs",
        name="RuInside",
        desc="Russian domestic services & government portals (Direct connection)",
        rules=rules,
        source_url=" + ".join(urls),
        routing=1,  # 1 = DIRECT
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
        
        # Split into chunks if > 100k
        if len(rules) <= MAX_RULES_PER_SET:
            write_arrs(out_dir / f"{name}.arrs", name, meta["desc"], rules, meta["url"], meta["routing"])
        else:
            for idx in range(0, len(rules), MAX_RULES_PER_SET):
                part = (idx // MAX_RULES_PER_SET) + 1
                part_rules = rules[idx:idx + MAX_RULES_PER_SET]
                part_name = f"{name}_{part:02d}"
                write_arrs(out_dir / f"{part_name}.arrs", part_name, f"{meta['desc']} (Part {part})", part_rules, meta["url"], meta["routing"])

    build_ru_inside(out_dir)
    print("Done!")


if __name__ == "__main__":
    main()
