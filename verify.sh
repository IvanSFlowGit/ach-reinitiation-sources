#!/usr/bin/env bash
# Re-runs the measurement in README.md against the live Federal Reserve document.
# Exits 0 only if the controls fire. A zero from a broken extraction and a zero
# from a clean document are the same number; only one of them means anything.
set -euo pipefail

UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/126 Safari/537.36'
IDX='https://www.frbservices.org/resources/rules-regulations/operating-circulars.html'
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

command -v pdftotext >/dev/null || { echo "need pdftotext (poppler)"; exit 2; }

echo "resolving the current OC 4 from the Fed's own index"
PDF=$(curl -sfL -A "$UA" "$IDX" \
      | grep -o '[^"]*operating-circular-4\.pdf' \
      | grep -v redline | sort -r | head -1)
[ -n "$PDF" ] || { echo "could not find OC 4 on the index page"; exit 2; }
echo "  $PDF"

curl -sfL -A "$UA" -o oc4.pdf "https://www.frbservices.org$PDF"
[ -s oc4.pdf ] || { echo "empty download"; exit 2; }
pdftotext -layout oc4.pdf oc4.txt

python3 - <<'PY'
import re, sys
a = re.sub(r'\s+', ' ', open('oc4.txt', encoding='utf-8', errors='replace').read())

# Controls. Without these a zero below proves nothing.
if 'Automated Clearing House Items' not in a:
    sys.exit("CONTROL FAILED: known-true term absent, extraction is broken")
if 'zzq-not-in-this-document' in a:
    sys.exit("CONTROL FAILED: fabricated term present, matcher is broken")
print("controls ok: known-true term present, fabricated term absent")
print(f"population: {len(a)} characters of extracted text")

terms = {
    'reinitiat':          r'reinitiat',
    'return entry':       r'\breturn(?:ed)? entr',
    'R-code (R01-R85)':   r'\bR\d{2}\b',
    '"180 days"':         r'180\s+days',
    '"30 days"':          r'\b30\s+days',
    'Nacha':              r'\bNacha\b',
}
for name, pat in terms.items():
    print(f"  {name:20} {len(re.findall(pat, a, re.I))}")

print("\nThe rule is not in this document. It is incorporated by reference from the")
print("Nacha Operating Rules, which are sold rather than published. See README.md.")
PY
