; extends

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#eq? @_lang "SQL")
  (#set! injection.language "sql"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#eq? @_lang "PY")
  (#set! injection.language "python"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#eq? @_lang "LUA")
  (#set! injection.language "lua"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#eq? @_lang "JS")
  (#set! injection.language "javascript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#eq? @_lang "TS")
  (#set! injection.language "typescript"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#any-of? @_lang "RB" "RUBY")
  (#set! injection.language "ruby"))

((heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @_lang)
  (#any-of? @_lang "PL" "PERL")
  (#set! injection.language "perl"))
