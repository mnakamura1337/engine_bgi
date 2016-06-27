meta:
  id: bgi_arc
  application: BGI (Buriko General Interpreter)
  file-extension: arc
  endian: le
seq:
  - id: magic
    contents:
      - 'PackFile    '
  - id: qty_files
    type: u4
  - id: files
    type: file_entry
    repeat: expr
    repeat-expr: qty_files
types:
  file_entry:
    seq:
      - id: file_name
        type: str
        size: 16
        encoding: UTF-8
      - id: offset
        type: u4
      - id: len
        type: u4
      - id: rest
        size: 8
    instances:
      contents:
        io: _root._io
        pos: offset + 0x10 + 0x20 * _root.qty_files
        size: len
