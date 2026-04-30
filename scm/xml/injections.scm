; extends

; MyBatis mapper SQL statement bodies.
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CharData) @injection.content)
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql"
    "where"
    "set"
    "trim"
    "foreach"
    "if"
    "choose"
    "when"
    "otherwise")
  (#any-of? @_end_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql"
    "where"
    "set"
    "trim"
    "foreach"
    "if"
    "choose"
    "when"
    "otherwise")
  (#set! injection.language "sql")
)

; MyBatis mapper SQL inside CDATA.
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CDSect
        (CData) @injection.content))
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql"
    "where"
    "set"
    "trim"
    "foreach"
    "if"
    "choose"
    "when"
    "otherwise")
  (#any-of? @_end_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql"
    "where"
    "set"
    "trim"
    "foreach"
    "if"
    "choose"
    "when"
    "otherwise")
  (#set! injection.language "sql")
)
