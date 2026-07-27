#!/usr/bin/env python3
import os
import re
import sys

content = open('CHANGELOG.md').read()
version = os.environ['VERSION']
pattern = rf'## \[{re.escape(version)}\].*?(?=\n## \[|\Z)'
match = re.search(pattern, content, re.DOTALL)
if not match:
    print(
        f'::error::No CHANGELOG.md section found for [{version}]. Fill it in before merging.',
        file=sys.stderr,
    )
    sys.exit(1)

body = match.group(0).strip()
body = re.sub(r'\n+---\s*$', '', body).strip()
content_lines = [
    line
    for line in body.splitlines()
    if line.strip()
    and not line.startswith('#')
    and not line.startswith('**Upstream release:')
]
if not content_lines:
    print(
        f'::error::CHANGELOG.md section for [{version}] has no content. Fill it in before merging.',
        file=sys.stderr,
    )
    sys.exit(1)

if os.environ.get('EXTRACT_RELEASE_NOTES', 'false').lower() == 'true':
    release_notes_path = os.environ.get('RELEASE_NOTES_PATH', '/tmp/release-notes.md')
    with open(release_notes_path, 'w') as file:
        file.write(body)
