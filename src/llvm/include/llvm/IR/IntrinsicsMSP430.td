//===- IntrinsicsMSP430.td - Defines MSP430 intrinsics -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the MSP430-specific intrinsics.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "msp430" in {  // All intrinsics start with "llvm.msp430."
  def int_msp430_bic_saved_status :
              Intrinsic<[llvm_i16_ty], [llvm_i16_ty], []>,
              GCCBuiltin<"__bic_SR_register_on_exit">;
  def int_msp430_bis_saved_status :
              Intrinsic<[llvm_i16_ty], [llvm_i16_ty], []>,
              GCCBuiltin<"__bis_SR_register_on_exit">;
}
