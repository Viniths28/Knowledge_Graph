import os, sys, json, difflib

ROOT = os.path.dirname(__file__)
ORIGINAL_DIR = ROOT
PARSED_DIR = os.path.join(ROOT, 'import', 'parsed')

orig_files = [f for f in os.listdir(ORIGINAL_DIR) if f.lower().endswith('.json')]

missing = []
errors = []

for fname in orig_files:
    parsed_path = os.path.join(PARSED_DIR, fname)
    if not os.path.exists(parsed_path):
        missing.append(fname)
        continue
    with open(os.path.join(ORIGINAL_DIR, fname), 'r', encoding='utf-8') as f:
        raw = f.read()
    idx = raw.find('{')
    if idx == -1:
        errors.append((fname, 'No opening brace found in original'))
        continue
    cleaned = raw[idx:]

    with open(parsed_path, 'r', encoding='utf-8') as f:
        parsed_content = f.read()

    if cleaned != parsed_content:
        # Produce a short diff
        diff = difflib.unified_diff(
            cleaned.splitlines(),
            parsed_content.splitlines(),
            fromfile=fname + ' (cleaned)',
            tofile=fname + ' (parsed)',
            lineterm=''
        )
        diff_text = '\n'.join(list(diff)[:20])  # first 20 diff lines
        errors.append((fname, 'Content mismatch', diff_text))

print(f'Total original files: {len(orig_files)}')
print(f'Files missing parsed version: {len(missing)}')
for m in missing:
    print('  -', m)
print(f'Files with errors: {len(errors)}')
for fname, msg, *rest in errors:
    print(f'  - {fname}: {msg}')
    if rest:
        print(rest[0])

if not missing and not errors:
    print('\nAll parsed files match cleaned originals. ✅')
    sys.exit(0)
else:
    sys.exit(1) 