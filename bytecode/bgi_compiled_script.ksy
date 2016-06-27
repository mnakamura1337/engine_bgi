meta:
  id: bgi_compiled_script
  application: BGI (Buriko General Interpreter)
  endian: le
seq:
  - id: magic
    contents: [
      "BurikoCompiledScriptVer1.00", 0,
      0x14, 2, 0, 0,
      0, 0, 0, 0,
    ]
  - id: num_subs
    type: u4
  - id: subs
    type: sub
    repeat: expr
    repeat-expr: num_subs
  - id: padding
    size: 14
  - id: body
    type: bgi_bytecode
    size-eos: true
types:
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
