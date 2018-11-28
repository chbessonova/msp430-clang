//===-- MSP430InstPrinter.cpp - Convert MSP430 MCInst to assembly syntax --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an MSP430 MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "MSP430InstPrinter.h"
#include "MSP430.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

// Include the auto-generated portion of the assembly writer.
#define PRINT_ALIAS_INSTR
#include "MSP430GenAsmWriter.inc"

static bool isRLAmInstruction(const MCInst *MI) {
  // add x,x == rla x
  unsigned Opc = MI->getOpcode();
  if (Opc != MSP430::ADD8mm && Opc != MSP430::ADD16mm &&
      Opc != MSP430::ADDC8mm && Opc != MSP430::ADDC16mm)
    return false;

  // Check operands pairs are equal
  const MCOperand &Op1 = MI->getOperand(0);
  const MCOperand &Op2 = MI->getOperand(1);
  const MCOperand &Op3 = MI->getOperand(2);
  const MCOperand &Op4 = MI->getOperand(3);

  if (Op1.isReg() && Op3.isReg() && Op1.getReg() == Op3.getReg() &&
      Op2.isImm() && Op4.isImm() && Op2.getImm() == Op4.getImm())
      return true;
  // TODO: Is it possible to check if two MCExpr are equal?
  return false;
}

void MSP430InstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                  StringRef Annot, const MCSubtargetInfo &STI) {
  // Print add x,x -> rla x (only mm case here, rr is handled by tablegen)
  // TODO: Is it possible to resolve this by tablegen as well?
  if (isRLAmInstruction(MI)) {
    switch (MI->getOpcode()) {
    case MSP430::ADD8mm:     O << "\trla.b\t";        break;
    case MSP430::ADD16mm:    O << "\trla\t";          break;
    case MSP430::ADDC8mm:    O << "\trlc.b\t";        break;
    case MSP430::ADDC16mm:   O << "\trlc\t";          break;
    default:
      llvm_unreachable("Unexpected instruction");
    }
    printSrcMemOperand(MI, 0, O);
    printAnnotation(O, Annot);
    return;
  }

  if (!printAliasInstr(MI, O))
    printInstruction(MI, O);

  printAnnotation(O, Annot);
}

void MSP430InstPrinter::printPCRelImmOperand(const MCInst *MI, unsigned OpNo,
                                             raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isImm()) {
    int64_t Imm = Op.getImm() * 2 + 2;
    O << "$";
    if (Imm >= 0)
      O << '+';
    O << Imm;
  } else {
    assert(Op.isExpr() && "unknown pcrel immediate operand");
    Op.getExpr()->print(O, &MAI);
  }
}

void MSP430InstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O, const char *Modifier) {
  assert((Modifier == nullptr || Modifier[0] == 0) && "No modifiers supported");
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    O << getRegisterName(Op.getReg());
  } else if (Op.isImm()) {
    O << '#' << Op.getImm();
  } else {
    assert(Op.isExpr() && "unknown operand kind in printOperand");
    O << '#';
    Op.getExpr()->print(O, &MAI);
  }
}

void MSP430InstPrinter::printSrcMemOperand(const MCInst *MI, unsigned OpNo,
                                           raw_ostream &O,
                                           const char *Modifier) {
  const MCOperand &Base = MI->getOperand(OpNo);
  const MCOperand &Disp = MI->getOperand(OpNo+1);
  assert(Disp.isImm() ||
         Disp.isExpr() && "Unexpected type in displacement field");

  // If the global address expression is a part of displacement field with a
  // register base, we should not emit any prefix symbol here, e.g.
  //   mov.w &foo, r1
  // vs
  //   mov.w glb(r1), r2
  // Otherwise (!) msp430-as will silently miscompile the output :(
  if (Base.getReg() == MSP430::SR)
    O << '&';

  if (Base.getReg() == MSP430::SR || Base.getReg() == MSP430::PC) {
    if (Disp.isExpr())
      Disp.getExpr()->print(O, &MAI);
    else
      O << Disp.getImm();
    return;
  }

  // Print 0(Rn) as @Rn
  if (Disp.isImm() && Disp.getImm() == 0) {
    O << '@' << getRegisterName(Base.getReg());
    return;
  }

  if (Disp.isExpr())
    Disp.getExpr()->print(O, &MAI);
  else
    O << Disp.getImm();

  O << '(' << getRegisterName(Base.getReg()) << ')';
}

void MSP430InstPrinter::printIndRegOperand(const MCInst *MI, unsigned OpNo,
                                           raw_ostream &O) {
  const MCOperand &Base = MI->getOperand(OpNo);
  O << "@" << getRegisterName(Base.getReg());
}

void MSP430InstPrinter::printPostIndRegOperand(const MCInst *MI, unsigned OpNo,
                                               raw_ostream &O) {
  const MCOperand &Base = MI->getOperand(OpNo);
  O << "@" << getRegisterName(Base.getReg()) << "+";
}

void MSP430InstPrinter::printCCOperand(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O) {
  unsigned CC = MI->getOperand(OpNo).getImm();

  switch (CC) {
  default:
   llvm_unreachable("Unsupported CC code");
  case MSP430CC::COND_E:
   O << "eq";
   break;
  case MSP430CC::COND_NE:
   O << "ne";
   break;
  case MSP430CC::COND_HS:
   O << "hs";
   break;
  case MSP430CC::COND_LO:
   O << "lo";
   break;
  case MSP430CC::COND_GE:
   O << "ge";
   break;
  case MSP430CC::COND_L:
   O << 'l';
   break;
  case MSP430CC::COND_N:
   O << 'n';
   break;
  }
}
