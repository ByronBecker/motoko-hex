/**
 * Module      : Hex.mo
 * Description : Hexadecimal encoding and decoding routines.
 * Copyright   : 2020 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Stable
 *
 *
 * Note: Updated by Byron Becker in 2022 (Independent of DFINITY)
 */

import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat8 "mo:base/Nat8";
import Char "mo:base/Char";
import Result "mo:base/Result";

module {

  private type Result<Ok, Err> = Result.Result<Ok, Err>;

  private let base : Nat8 = 0x10;

  private let lowerSymbols = [
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ];
  private let upperSymbols = [
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  ];

  /**
   * Define a type to indicate that the decoder has failed.
   */
  public type DecodeError = {
    #msg : Text;
  };

  public type Casing = { #upper; #lower };

  /**
   * Encode an array of unsigned 8-bit integers in hexadecimal format.
   */
  public func encode(array : [Nat8], characterCasing: Casing) : Text {
    Array.foldLeft<Nat8, Text>(array, "", func (accum, w8) {
      accum # encodeW8(w8, characterCasing);
    });
  };

  /**
   * Encode an unsigned 8-bit integer in hexadecimal format.
   */
  private func encodeW8(w8 : Nat8, characterCasing: Casing) : Text {
    let symbols = switch(characterCasing) {
      case (#upper) { upperSymbols };
      case (#lower) { lowerSymbols };
    };
    let c1 = symbols[Nat8.toNat(w8 / base)];
    let c2 = symbols[Nat8.toNat(w8 % base)];
    Char.toText(c1) # Char.toText(c2);
  };

  /**
   * Decode an array of unsigned 8-bit integers in hexadecimal format.
   */
  public func decode(text : Text, characterCasing: Casing) : Result<[Nat8], DecodeError> {
    let next = text.chars().next;
    func parse() : Result<Nat8, DecodeError> {
      Option.get<Result<Nat8, DecodeError>>(
        do ? {
          let c1 = next()!;
          let c2 = next()!;
          Result.chain<Nat8, Nat8, DecodeError>(decodeW4(c1, characterCasing), func (x1) {
            Result.chain<Nat8, Nat8, DecodeError>(decodeW4(c2, characterCasing), func (x2) {
                #ok (x1 * base + x2);
            })
          })
        },
        #err (#msg "Not enough input!"),
      );
    };
    var i = 0;
    let n = text.size() / 2 + text.size() % 2;
    let array = Array.init<Nat8>(n, 0);
    while (i != n) {
      switch (parse()) {
        case (#ok w8) {
          array[i] := w8;
          i += 1;
        };
        case (#err err) {
          return #err err;
        };
      };
    };
    #ok (Array.freeze<Nat8>(array));
  };

  /**
   * Decode an unsigned 4-bit integer in hexadecimal format.
   */
  private func decodeW4(char : Char, characterCasing: Casing) : Result<Nat8, DecodeError> {
    let symbols = switch(characterCasing) {
      case (#upper) { upperSymbols };
      case (#lower) { lowerSymbols };
    };
    for (i in Iter.range(0, 15)) {
      if (symbols[i] == char) {
        return #ok (Nat8.fromNat(i));
      };
    };
    let str = "Unexpected character: " # Char.toText(char);
    #err (#msg str);
  };
};
