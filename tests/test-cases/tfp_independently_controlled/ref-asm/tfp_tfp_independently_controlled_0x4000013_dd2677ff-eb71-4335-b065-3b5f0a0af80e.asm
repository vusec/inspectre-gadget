--------------------- TFP ----------------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10] ; {Attacker@rdi} -> {Attacker@0x400000f}
4000013  call    rax ; {Attacker@0x400000f} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: dd2677ff-eb71-4335-b065-3b5f0a0af80e

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
Tainted Function Pointer:
  - Reg: rax
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
  - Control: ControlType.CONTROLLED
  - Register Requirements: {<BV64 rdi>}

Constraints: []
Branches: []

Controlled Regs:
  - Reg: rax
    Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
    ControlType: TFPRegisterControlType.IS_TFP_REGISTER
    Controlled Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rbx
    Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdi>]_20>]_22>
    ControlType: TFPRegisterControlType.POTENTIAL_SECRET
    Controlled Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdi>]_20>]_22>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rcx
    Expr: <BV64 rcx + LOAD_64[<BV64 rdi>]_20 + LOAD_64[<BV64 rdx>]_21>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 rcx + LOAD_64[<BV64 rdi>]_20 + LOAD_64[<BV64 rdx>]_21>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rdx
    Expr: <BV64 LOAD_64[<BV64 rdx>]_21>
    ControlType: TFPRegisterControlType.POTENTIAL_SECRET
    Controlled Expr: <BV64 LOAD_64[<BV64 rdx>]_21>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rsi
    Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
    ControlType: TFPRegisterControlType.CONTROLLED
    Controlled Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
    Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
  - Reg: rdi
    Expr: <BV64 rdi>
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR
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
    Controlled Range w Branches:(0x0,0xffffffffffffffff, 0x1) Exact: True
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
  - Reg: rdi
    Expr: <BV64 rdi>
    Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
    ControlType: TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: ['rbx', 'rdx']

------------------------------------------------
