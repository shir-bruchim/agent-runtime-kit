#!/usr/bin/env python3
"""
validate-references.py — Check repo-relative file references in key docs.

Scans README.md, AGENT-SETUP.md, and skills/*/SKILL.md for repo-relative
paths and fails if any referenced path is missing.

Usage:
    python3 scripts/validate-references.py [--root REPO_ROOT]

Exit codes:
    0 = all references valid
    1 = one or more broken references found
"""

import os
import re
import sys
import argparse

def find_repo_root():
    """Walk up from script location to find repo root (contains README.md)."""
    d = os.path.dirname(os.path.abspath(__file__))
    for _ in range(5):
        if os.path.exists(os.path.join(d, "README.md")):
            return d
        d = os.path.dirname(d)
    return os.getcwd()


def extract_references(content: str, file_path: str):
    """Extract repo-relative path references from markdown content."""
    refs = []

    # Markdown links: [text](path) — only local paths (no http, no #anchor-only)
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', content):
        path = m.group(2).split('#')[0].strip()
        if path and not path.startswith(('http', 'mailto', '#')):
            refs.append((path, m.start()))

    # Code blocks with paths: skills/..., subagents/..., rules/..., etc.
    path_pattern = re.compile(
        r'(?:^|\s|`|\'|")'
        r'((?:skills|subagents|commands|rules|languages|mcp|docs|templates|scripts|\.github)'
        r'/[a-zA-Z0-9_\-./]+\.[a-zA-Z]{1,5})'
        r'(?:\s|`|\'|"|$)',
        re.MULTILINE
    )
    for m in path_pattern.finditer(content):
        path = m.group(1).strip()
        if path:
            refs.append((path, m.start()))

    # Bare directory references like `skills/extend-agent/`
    dir_pattern = re.compile(
        r'`((?:skills|subagents|commands|rules|languages|mcp|docs|templates|scripts)'
        r'/[a-zA-Z0-9_\-./]+/)`'
    )
    for m in dir_pattern.finditer(content):
        refs.append((m.group(1).rstrip('/'), m.start()))

    return refs


def check_file(repo_root: str, doc_path: str, errors: list):
    """Check all references in a single file."""
    if not os.path.exists(doc_path):
        return

    with open(doc_path) as f:
        content = f.read()

    refs = extract_references(content, doc_path)
    doc_dir = os.path.dirname(doc_path)

    seen = set()
    for ref_path, pos in refs:
        # Normalise: strip leading ./ but preserve dotdirectory names (.github)
        if ref_path.startswith('./'):
            ref_path = ref_path[2:]

        if ref_path in seen:
            continue
        seen.add(ref_path)

        # Try as repo-relative first
        abs_path = os.path.join(repo_root, ref_path)
        if os.path.exists(abs_path):
            continue

        # Try as relative to the doc's directory
        abs_path2 = os.path.normpath(os.path.join(doc_dir, ref_path))
        if os.path.exists(abs_path2):
            continue

        # Broken reference
        line_num = content[:pos].count('\n') + 1
        rel_doc = os.path.relpath(doc_path, repo_root)
        errors.append(f"  {rel_doc}:{line_num}: missing → {ref_path}")


def main():
    parser = argparse.ArgumentParser(description="Validate repo-relative references in docs")
    parser.add_argument("--root", default=None, help="Repo root (default: auto-detect)")
    args = parser.parse_args()

    repo_root = args.root or find_repo_root()
    print(f"Repo root: {repo_root}")

    # Files to scan
    scan_files = [
        os.path.join(repo_root, "README.md"),
        os.path.join(repo_root, "AGENT-SETUP.md"),
        os.path.join(repo_root, "PROFILES.md"),
    ]

    # Add all SKILL.md files
    skills_dir = os.path.join(repo_root, "skills")
    if os.path.isdir(skills_dir):
        for skill_name in os.listdir(skills_dir):
            skill_md = os.path.join(skills_dir, skill_name, "SKILL.md")
            if os.path.exists(skill_md):
                scan_files.append(skill_md)

    errors = []
    for doc in scan_files:
        if os.path.exists(doc):
            check_file(repo_root, doc, errors)

    if errors:
        print(f"\n❌ Found {len(errors)} broken reference(s):\n")
        for e in errors:
            print(e)
        sys.exit(1)
    else:
        print(f"✓ All references valid (scanned {len(scan_files)} files)")
        sys.exit(0)


if __name__ == "__main__":
    main()