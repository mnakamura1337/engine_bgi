meta:
  id: bgi_compiled_script
  imports:
    - bgi_bytecode
  application: BGI (Buriko General Interpreter)
  endian: le
seq:
  - id: magic
    contents: [ "BurikoCompiledScriptVer1.00", 0 ]
    doc: VER100 header ft. subs table
  - id: header_size
    type: u4
    doc: not including magic
  - id: num_namespaces
    type: u4
  - id: namespaces
    type: namespace
    repeat: expr
    repeat-expr: num_namespaces
  - id: num_subs
    type: u4
  - id: subs
    type: sub
    repeat: expr
    repeat-expr: num_subs
instances:
  body:
    type: bgi_bytecode
    pos: header_size + 0x1C
    size-eos: true
types:
  namespace:
    seq:
      - id: name
        type: strz
        encoding: SJIS
  sub:
    seq:
      - id: name
        type: strz
        encoding: SJIS
      - id: addr
        type: u4
  header:
    seq:
      - id: smth1
        type: u4
      - id: smth2
        type: u4
      - id: smth3
        type: u4
      - id: smth4
        type: u4
      - id: smth5
        type: u4
      - id: smth6
        type: u4
      - id: bytecode_len
        type: u4
