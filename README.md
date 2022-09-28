## The Hex Package

[![Build Status](https://github.com/enzoh/motoko-hex/workflows/build/badge.svg)](https://github.com/enzoh/motoko-hex/actions?query=workflow%3Abuild)

This package implements hexadecimal encoding and decoding routines for the Motoko programming language.

### Prerequisites

- DFINITY SDK
- Vessel

### Usage

Encode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func encode(array : [Nat8], characterCasing: { #upper; #lower }) : Text
```

Decode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func decode(text : Text, characterCasing: { #upper; #lower }) : Result<[Nat8], DecodeError> 
```
