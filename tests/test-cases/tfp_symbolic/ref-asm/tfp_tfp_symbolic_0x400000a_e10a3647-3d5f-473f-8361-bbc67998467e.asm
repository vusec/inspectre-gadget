--------------------- TFP ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1
         tfp0:
4000006  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@rsi} -> {Attacker@0x4000006}
400000a  call    rax ; {Attacker@0x4000006} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: e10a3647-3d5f-473f-8361-bbc67998467e

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
Tainted Function Pointer:
  - Reg: rax
  - Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
  - Control: ControlType.CONTROLLED
  - Register Requirements: {<BV64 rcx>, <BV64 rsi>}

Constraints: []
Branches: []

Controlled Regs:
  - Reg: rax
    Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
    ControlType: TFPRegisterControlType.IS_TFP_REGISTER
    Controlled Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rbx
    Expr: <BV64 rbx>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rbx>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rcx
    Expr: <BV64 rcx>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rcx>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rdx
    Expr: <BV64 rdx>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rdx>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsi
    Expr: <BV64 rsi>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsi>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rdi
    Expr: <BV64 rdi>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rdi>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r8
    Expr: <BV64 r8>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r8>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r9
    Expr: <BV64 r9>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r9>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r10
    Expr: <BV64 r10>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r10>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r11
    Expr: <BV64 r11>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r11>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r12
    Expr: <BV64 r12>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r12>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r13
    Expr: <BV64 r13>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r13>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r14
    Expr: <BV64 r14>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r14>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: r15
    Expr: <BV64 r15>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 r15>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x1,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_8
    Expr: <BV64 rsp_0>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_0>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_16
    Expr: <BV64 rsp_8>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_8>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_24
    Expr: <BV64 rsp_16>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_16>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_32
    Expr: <BV64 rsp_24>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_24>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_40
    Expr: <BV64 rsp_32>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_32>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_48
    Expr: <BV64 rsp_40>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_40>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_56
    Expr: <BV64 rsp_48>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_48>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_64
    Expr: <BV64 rsp_56>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_56>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_72
    Expr: <BV64 rsp_64>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_64>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_80
    Expr: <BV64 rsp_72>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_72>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_88
    Expr: <BV64 rsp_80>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_80>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_96
    Expr: <BV64 rsp_88>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_88>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_104
    Expr: <BV64 rsp_96>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_96>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_112
    Expr: <BV64 rsp_104>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_104>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_120
    Expr: <BV64 rsp_112>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_112>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_128
    Expr: <BV64 rsp_120>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_120>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_136
    Expr: <BV64 rsp_128>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_128>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_144
    Expr: <BV64 rsp_136>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_136>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_152
    Expr: <BV64 rsp_144>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rsp_144>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True

Registers aliasing with tfp:

Registers aliasing with tfp:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
