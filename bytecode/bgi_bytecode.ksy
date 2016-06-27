meta:
  id: bgi_bytecode
  endian: le
seq:
  - id: header
    type: header
  - id: bytecode
    size: header.bytecode_len
    type: bytecode
  - id: strings
    size-eos: true
types:
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
  bytecode:
    seq:
      - id: entries
        type: bytecode_entry
        repeat: eos
  bytecode_entry:
    seq:
      - id: opcode
        type: u4
      - id: op_debug_info
        type: op_debug_info
        if: opcode == 0x7f
      - id: op_int
        type: op_int
        if: opcode == 0
      - id: op_addr
        type: op_addr
        if: opcode == 1
      - id: op_str
        type: op_str
        if: opcode == 3
      - id: op_cmd19
        type: op_cmd19
        if: opcode == 0x19
  op_int:
    seq:
      - id: val
        type: s4
  op_addr:
    seq:
      - id: val
        type: s4
  op_cmd19:
    seq:
      - id: smth
        type: u4
  op_str:
    seq:
      - id: offset
        type: u4
    instances:
      str:
        io: _parent._parent._parent._io
        pos: offset
        type: strz
        encoding: SJIS
  op_debug_info:
    seq:
      - id: file_name_offset
        type: u4
      - id: line_num
        type: u4
    instances:
      file_name:
        io: _parent._parent._parent._io
        pos: file_name_offset
        type: strz
        encoding: SJIS
