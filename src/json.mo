import Array "mo:stdlib/array";
import Debug "mo:stdlib/debug";
import HM "mo:stdlib/hashMap";
import Hash "mo:stdlib/hash";
import Int "mo:stdlib/int";
import Iter "mo:stdlib/iter";
import List "mo:stdlib/list";
import Option "mo:stdlib/option";
import P "mo:parsec/parsec";
import Prim "mo:prim";
import Utils "utils";

module {
public type Json = {
    #number: Int;
    #string: Text;
    #jnull;
    #array: [Json];
    #obj: HM.HashMap<Text, Json>
};

public func jNumber(i: Int): Json = #number(i);
public func jString(s: Text): Json = #string(s);
public func jArray(a: [Json]): Json = #array(a);
public func jObj(o: HM.HashMap<Text, Json>): Json = #obj(o);

func arrayToText<A>(fmt: A -> Text, as: [A]): Text {
    let vs = List.fromArray(as);
    switch vs {
    case null "[]";
    case (?(v, t)) {
             let res = List.foldLeft(
               t,
               fmt v,
               func (v: A, acc: Text): Text = acc # ", " # fmt v);
             "[ " # res # " ]"
         }
    }
};

func hmToText<K, V>(fmtKey: K -> Text, fmtValue: V -> Text, hm: HM.HashMap<K, V>): Text {
    let vs = Iter.toList(hm.iter());

    switch vs {
    case null "{}";
    case (?((k, v), t)) {
             let res = List.foldLeft(
               t,
               fmtKey k # ": " # fmtValue v,
               func ((k: K, v: V), acc: Text): Text = acc # ", " # fmtKey k # ": " # fmtValue v);
             "{ " # res # " }"
         }
    }
};

public func toText(json: Json): Text {
    switch(json) {
        case (#number i) Int.toText i;
        // TODO Escape string
        case (#string s) "\"" # s # "\"";
        case (#jnull) "null";
        case (#array js) arrayToText<Json>(toText, js);
        case (#obj obj) hmToText<Text, Json>(func x = x, toText, obj);
    }
};

type Parser<A> = P.Parser<Char, A>;

public func parse(input: Text): ?Json {
    let cp = P.CharParsers();
    func char(char: Char): Parser<Char> {
        P.satisfy(func (c: Char): Bool = c == char)
    };
    let nullParser =
        cp.lexeme(P.map(cp.token("null"), func (_: Text): Json = #jnull));

    let numberParser: Parser<Json> = {
        P.bind(P.many1(P.choose(char('-'))(cp.digit)), func(cs: List.List<Char>): Parser<Json> {
            switch (Utils.intFromIter(Iter.fromList(cs))) {
            case null {
                         Debug.print("Cancelled.");
                         P.mzero()
                 };
            case (?i) {
                     Debug.print("Int: " # Int.toText i);
                     P.ret<Char, Json>(jNumber i)
                 }
            }

        })
    };

    let stringLiteral: Parser<Text> = {
        let any: Parser<Char> = func ls = P.any ls;
        let chars = P.between(char('\"'), P.many(P.satisfy (func (c: Char): Bool = c != '\"')), char('\"'));
        P.map(chars,
            func(cs: List.List<Char>): Text = Utils.charIterToText (Iter.fromList cs))
    };

    let stringParser: Parser<Json> = P.map(stringLiteral, jString);

    func arrayParser(): Parser<Json> {
        let arrayContents = P.sepBy(P.delay jsonParser, char ',');
        P.map(P.between(char '[', arrayContents, char ']'), func (es: List.List<Json>): Json = jArray(List.toArray es))
    };

    func objectParser(): Parser<Json> {
        let objectField = P.pair(P.left(stringLiteral, char ':'), P.delay jsonParser);
        let objectContents = P.sepBy(objectField, char ',');
        let textEq = func(x: Text, y: Text): Bool = x == y;
        let mkObj = func(es: List.List<(Text, Json)>): Json =
          jObj(HM.fromIter<Text, Json>(Iter.fromList es, 0, textEq, Hash.hashOfText));
        P.map(P.between(char '{', objectContents, char '}'), mkObj)
    };

    func jsonParser(): P.Parser<Char, Json> {
      P.choice (List.fromArray([
        nullParser,
        numberParser,
        stringParser,
        arrayParser(),
        objectParser()
      ]))
    };

    switch (jsonParser()(P.LazyStream.ofIter(input.chars()))) {
      case null null;
      case (?(j, _)) ?j;
    }
};
};
