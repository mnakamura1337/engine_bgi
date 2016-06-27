meta:
  id: bgi_bw_ogg
  application: BGI (Buriko General Interpreter)
  endian: le
seq:
  - id: magic
    contents:
      - 0x40
      - 0
      - 0
      - 0
      - 'bw  '
  - id: file_size
    type: u4
  - id: sample_len
    type: u4
  - id: freq
    type: u4
  - id: channels
    type: u4
  - id: smth1
    type: u4
  - id: smth2
    type: u4
  - id: empty1
    size: 16
  - id: smth5
    type: u4
  - id: empty2
    size: 12
  - id: body
    size: file_size
  - id: rest
    size-eos: true
