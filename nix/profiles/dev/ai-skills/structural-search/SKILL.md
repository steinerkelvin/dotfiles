---
name: structural-search
description: Use structural code search and rewrite tools (ast-grep, comby, tree-sitter) for code analysis and refactoring
---

# Structural Code Tools

## ast-grep (sg)

Language-aware structural search/replace using AST patterns.

- `sg --pattern 'console.log($$$ARGS)' --lang js` — find all console.log calls
- `sg --pattern '$FUNC($$$ARGS)' --rewrite 'newFunc($$$ARGS)' --lang py` — rename function calls
- Best for: language-specific refactors, finding code by syntactic structure

## comby

Language-aware structural search/replace with simple hole-matching syntax.

- `comby ':[fn](:[args])' 'new_:[fn](:[args])' .py` — rename function calls
- `comby 'if :[cond] { :[body] }' 'when :[cond] { :[body] }' .rs` — syntax migration
- Best for: cross-format patterns (configs, HTML, etc.), simpler than ast-grep

## tree-sitter

Dump/inspect the AST of a file to understand its structure.

- `tree-sitter parse file.py` — show full AST
- Best for: understanding code structure before making changes, unfamiliar languages
