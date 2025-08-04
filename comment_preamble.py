import os, pathlib
ROOT = pathlib.Path(__file__).parent
for json_path in ROOT.glob('*.json'):
    txt = json_path.read_text(encoding='utf-8')
    brace = txt.find('{')
    if brace <= 0:
        continue
    pre = txt[:brace]
    rest = txt[brace:]
    # If pre already commented, skip
    if pre.strip().startswith('//'):
        continue
    commented = '\n'.join('// ' + line for line in pre.rstrip('\n').splitlines()) + '\n'
    json_path.write_text(commented + rest, encoding='utf-8')
    print(f'Commented preamble in {json_path.name}') 