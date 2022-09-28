/**
 * Module      : Main.mo
 * Description : Unit tests.
 * Copyright   : 2020 DFINITY Stiftung
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Stable
 *
 *
 * Note: Updated by Byron Becker in 2022 (Independent of DFINITY)
 */



import Array "mo:base/Array";
import Hex "../src/Hex";
import Prelude "mo:base/Prelude";
import Result "mo:base/Result";
import Debug "mo:base/Debug";

type Result<Ok, Err> = Result.Result<Ok, Err>;

func eq(a : Nat8, b : Nat8) : Bool {
  a == b;
};

func unwrap(result : Result<[Nat8], Hex.DecodeError>) : [Nat8] {
  switch (result) {
    case (#ok blob) blob;
    case (#err err) Prelude.unreachable();
  }
};

func run() {
  let data : [Nat8] = [
    072, 101, 108, 108, 111, 032, 087, 111,
    114, 108, 100,
  ];
  let expect = #ok data;

  let actualLower = Hex.decode(Hex.encode(data, #lower), #lower);
  assert(Array.equal<Nat8>(unwrap(expect), unwrap(actualLower), eq));
  Debug.print("lower passed");

  let actualUpper = Hex.decode(Hex.encode(data, #upper), #upper);
  assert(Array.equal<Nat8>(unwrap(expect), unwrap(actualUpper), eq));
  Debug.print("upper passed");

  // lower casing encoding works
  assert "48656c6c6f20576f726c64" == Hex.encode(data, #lower);
  // upper casing encoding works
  assert "48656C6C6F20576F726C64" == Hex.encode(data, #upper);
};

run();
