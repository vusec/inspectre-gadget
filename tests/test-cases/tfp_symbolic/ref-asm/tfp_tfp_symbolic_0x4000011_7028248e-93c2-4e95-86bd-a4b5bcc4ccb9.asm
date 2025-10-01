--------------------- TFP ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1
         tfp1:
400000c  add     byte ptr [rdi], bh
400000e  cmovae  eax, ecx
4000011  jmp     qword ptr [rax-0x7db6bd40] ; {Attacker@0x4000011} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 7028248e-93c2-4e95-86bd-a4b5bcc4ccb9

Reg: mem
Expr: <BV64 LOAD_64[<BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>]_27>
Tainted Function Pointer:
  - Reg: mem
  - Expr: <BV64 LOAD_64[<BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>]_27>
  - Control: ControlType.CONTROLLED
  - Register Requirements: {<BV64 rcx>}

Constraints: []
Branches: []

Controlled Regs:
  - Reg: rax
    Expr: <BV64 0x0 .. rcx[31:0]>
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR
    Controlled Expr: <BV64 0#32 .. rcx[31:0]>
    Controlled Range: (0x0,0xffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffff, 0x1) Exact: True
  - Reg: rbx
    Expr: <BV64 rbx>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rbx>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: False
  - Reg: rcx
    Expr: <BV64 rcx>
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR
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
    Controlled Range w Branches:0x0
  - Reg: rdi_0
    Expr: <BV64 MEM_56[<BV64 rdi> + 8]_28 .. LOAD_8[<BV64 rdi>]_22 + rbx[15:8]>
    ControlType: TFPRegisterControlType.POTENTIAL_SECRET
    Controlled Expr: <BV64 (0#56 .. LOAD_8[<BV64 rdi>]_22) + (0#56 .. rbx[15:8])>
    Controlled Range: (0x0,0xff, 0x1) Exact: False
    Controlled Range w Branches:(0x0,0xff, 0x1) Exact: False
  - Reg: rsp_0
    Expr: <BV64 rsp_0>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_0>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_8
    Expr: <BV64 rsp_8>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_8>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_16
    Expr: <BV64 rsp_16>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_16>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_24
    Expr: <BV64 rsp_24>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_24>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_32
    Expr: <BV64 rsp_32>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_32>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_40
    Expr: <BV64 rsp_40>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_40>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_48
    Expr: <BV64 rsp_48>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_48>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_56
    Expr: <BV64 rsp_56>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_56>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_64
    Expr: <BV64 rsp_64>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_64>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_72
    Expr: <BV64 rsp_72>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_72>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_80
    Expr: <BV64 rsp_80>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_80>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_88
    Expr: <BV64 rsp_88>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_88>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_96
    Expr: <BV64 rsp_96>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_96>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_104
    Expr: <BV64 rsp_104>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_104>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_112
    Expr: <BV64 rsp_112>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_112>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_120
    Expr: <BV64 rsp_120>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_120>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_128
    Expr: <BV64 rsp_128>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_128>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_136
    Expr: <BV64 rsp_136>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_136>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_144
    Expr: <BV64 rsp_144>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_144>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsp_152
    Expr: <BV64 rsp_152>
    ControlType: TFPRegisterControlType.UNMODIFIED
    Controlled Expr: <BV64 rsp_152>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True

Registers aliasing with tfp:

Registers aliasing with tfp:
  - Reg: rax
    Expr: <BV64 0x0 .. rcx[31:0]>
    Range: (0x0,0xffffffff, 0x1) Exact: True
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR
  - Reg: rcx
    Expr: <BV64 rcx>
    Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15', 'rsp_0', 'rsp_8', 'rsp_16', 'rsp_24', 'rsp_32', 'rsp_40', 'rsp_48', 'rsp_56', 'rsp_64', 'rsp_72', 'rsp_80', 'rsp_88', 'rsp_96', 'rsp_104', 'rsp_112', 'rsp_120', 'rsp_128', 'rsp_136', 'rsp_144', 'rsp_152']
Potential Secrets: ['rdi_0']

------------------------------------------------
