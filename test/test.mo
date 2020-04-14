import Json "../src/Json";
import Debug "mo:base/Debug";

// switch(Json.parse("{\"hello\":\"world\",\"right\":\"dude\"}")) {
func testParse(t: Text) {
    Debug.print("\nAttempting to parse: " # t);
    switch(Json.parse t) {
        case null Debug.print "Failed to parse";
        case (?j) Debug.print(Json.toText j);
    }
};

testParse("123");
testParse("-123");
testParse("\"Hello\"");
testParse("[]");
testParse("[\"Hello\",\"Friend\"]");
testParse("[123]");
testParse("{\"hi\":\"friend\"}");
testParse("{\"hi\":-123}");
testParse("{\"hi\":\"friend\",\"test\":null}");
