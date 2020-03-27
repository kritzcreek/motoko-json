import Iter "mo:stdlib/Iter";
import Nat "mo:stdlib/Nat";
import Option "mo:stdlib/Option";
import Prim "mo:prim";

module {
public func digitFromChar(c: Char): ?Nat {
    switch(c) {
        case '0' ?0;
        case '1' ?1;
        case '2' ?2;
        case '3' ?3;
        case '4' ?4;
        case '5' ?5;
        case '6' ?6;
        case '7' ?7;
        case '8' ?8;
        case '9' ?9;
        case _ null;
    }
};

func natFromIter(iter: Iter.Iter<Char>, start: Nat, needsProgress: Bool): ?Nat {
    var res = start;
    var madeProgress = not needsProgress;
    label done : ()
    loop {
        switch(iter.next()) {
          case null break done;
          case (?d) switch (digitFromChar d) {
              case null break done;
              case (?n) {
                  madeProgress := true;
                  res *= 10;
                  res += n
              }
          }
        }
    };
    if (madeProgress) ?res else null
};

public func natFromText(t: Text): ?Nat {
    natFromIter(t.chars(), 0, true)
};

public func intFromIter(iter: Iter.Iter<Char>): ?Int {
    switch(iter.next()) {
        case null return null;
        case (?'-') Option.map<Nat, Int>(func x = -x, natFromIter(iter, 0, true));
        case (?d) {
            switch (digitFromChar d) {
                case null return null;
                case (?d) natFromIter(iter, d, false);
            }}
    }
};

public func intFromText(t: Text): ?Int {
    intFromIter(t.chars())
};

public func charIterToText(iter: Iter.Iter<Char>): Text {
    var res = "";
    for (c in iter) {
        res #= Prim.charToText c
    };
    res
};
}
