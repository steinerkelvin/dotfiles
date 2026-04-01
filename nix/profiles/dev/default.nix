{ ... }:

{
  imports = [
    ../base-dev
  ];

  programs.claude-code = {
    enable = true;

    skills = {
      uv-scripts = ''
        ---
        name: uv-scripts
        description: Use uv with PEP 723 inline metadata to run Python scripts with dependencies instead of installing packages globally
        ---

        # Python Scripts with uv

        **ALWAYS use `uv` to run Python scripts with dependencies** instead of installing
        packages globally with pip. Use inline metadata (PEP 723) for script dependencies.

        ```python
        #!/usr/bin/env -S uv run
        # /// script
        # dependencies = [
        #   "requests",
        #   "pandas",
        # ]
        # ///

        import requests
        import pandas as pd
        # ... your code
        ```

        Run with: `uv run script.py` or make executable with proper shebang.
      '';

      structural-search = ''
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
      '';

      code-stats = ''
        ---
        name: code-stats
        description: Get quick code statistics and project overview using tokei or scc
        ---

        # Code Statistics Tools

        ## tokei
        Fast code statistics by language.
        - `tokei` — stats for current directory
        - `tokei src/` — stats for specific path

        ## scc
        Fast code counter with complexity estimates.
        - `scc` — stats for current directory
        - `scc --by-file` — per-file breakdown
      '';
    };
  };
}
