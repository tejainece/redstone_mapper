library common_tests;

import "package:redstone_mapper/mapper.dart";
import 'package:test/test.dart';

import "domain.dart";

installCommonTests() {
  group("Encode:", () {
    test("Null value", () {
      expect(encode(null), equals(null));
    });

    test("Core types", () {
      expect(encode([1, 2, 3, 4]), equals([1, 2, 3, 4]));
    });

    test("Simple object", () {
      var obj = createSimpleObj();

      var data = encode(obj);

      expect(
          data,
          equals({
            "value1": "str",
            "value2": 10,
            "value3": true,
            "value4": dateTest.toIso8601String(),
            "property": {"value": "genericProperty"}
          }));
    });

    test("Ignore", () {
      final bImpulse = new TestObjIgnore();
      bImpulse.value1 = "str";
      bImpulse.value2 = 10;
      bImpulse.value3 = true;

      var data = encode(bImpulse);

      expect(
          data,
          equals({
            "value1": "str",
            "value2": 10,
          }));
    });

    test("Complex object", () {
      var obj = createComplexObj();

      var data = encode(obj);

      expect(
          data,
          equals({
            "value1": "str",
            "value2": 10,
            "value3": true,
            "value4": dateTest.toIso8601String(),
            "innerObj": {"innerObjValue": "obj1"},
            "innerObjs": [
              {"innerObjValue": "obj2"},
              {"innerObjValue": "obj3"}
            ],
            "mapInnerObjs": {
              1: {"innerObjValue": "obj1"},
              2: {"innerObjValue": "obj2"},
              3: {"innerObjValue": "obj3"}
            },
            "property": {"value": "specializedProperty"}
          }));
    });

    test("Mixin", () {
      var obj = createMixedUser();

      var data = encode(obj);

      expect(
          data,
          equals({
            "id":       "me",
            "username": "Alice",
            "password": "thereisnone",
          })
      );
    });

    test("List", () {
      var list = [createSimpleObj(), createSimpleObj()];

      var data = encode(list);
      var expected = {
        "value1": "str",
        "value2": 10,
        "value3": true,
        "value4": dateTest.toIso8601String(),
        "property": {"value": "genericProperty"}
      };

      expect(data, equals([expected, expected]));
    });
  });

  group("Decode:", () {
    test("Null value", () {
      expect(decode(null, TestObj), equals(null));
    });

    test("Core types", () {
      expect(decode([1, 2, 3, 4], int), equals([1, 2, 3, 4]));
    });

    test("Simple object", () {
      var obj = createSimpleObj();

      var data = {
        "value1": "str",
        "value2": 10,
        "value3": true,
        "value4": dateTest.toIso8601String(),
        "property": {"value": "genericProperty"}
      };

      var decoded = decode(data, TestObj);

      expect(decoded, equals(obj));
    });

    test("Ignore value", () {
      final bImpulse = new TestObjIgnore();
      bImpulse.value1 = "str";
      bImpulse.value2 = 10;
      bImpulse.value3 = null;

      var data = {
        "value1": "str",
        "value2": 10,
        "value3": true,
      };

      var decoded = decode(data, TestObjIgnore);

      expect(decoded, equals(bImpulse));
    });

    test("Complex object", () {
      var obj = createComplexObj();

      var data = {
        "value1": "str",
        "value2": 10,
        "value3": true,
        "value4": dateTest.toIso8601String(),
        "innerObj": {"innerObjValue": "obj1"},
        "innerObjs": [
          {"innerObjValue": "obj2"},
          {"innerObjValue": "obj3"}
        ],
        "mapInnerObjs": {
          1: {"innerObjValue": "obj1"},
          2: {"innerObjValue": "obj2"},
          3: {"innerObjValue": "obj3"}
        },
        "property": {"value": "specializedProperty"}
      };

      var decoded = decode(data, TestComplexObj);

      expect(decoded, equals(obj));
    });

    test("Mixin", () {
      var obj = createMixedUser();

      var data = {
        "id":       "me",
        "username": "Alice",
        "password": "thereisnone",
      };

      var decoded = decode(data, MixedUser);

      // TODO Equality not supported for mixed class
      // expect(decoded, equals(obj));
      expect(decoded.runtimeType, equals(obj.runtimeType));
      expect(decoded.toString(), equals(obj.toString()));
    });

    test("List", () {
      var data = {
        "value1": "str",
        "value2": 10,
        "value3": true,
        "value4": dateTest.toIso8601String(),
        "innerObj": {"innerObjValue": "obj1"},
        "innerObjs": [
          {"innerObjValue": "obj2"},
          {"innerObjValue": "obj3"}
        ],
        "mapInnerObjs": {
          1: {"innerObjValue": "obj1"},
          2: {"innerObjValue": "obj2"},
          3: {"innerObjValue": "obj3"}
        },
        "property": {"value": "specializedProperty"}
      };

      var list = [data, data];

      var decoded = decode(list, TestComplexObj);

      expect(decoded, equals([createComplexObj(), createComplexObj()]));
    });
  });

  group("Validator:", () {
    test("using validator object", () {
      var validator = new Validator(TestObj)
        ..add("value1", const Matches(r'\w+'))
        ..add("value2", const Range(min: 9, max: 12))
        ..add("value3", const NotEmpty());

      var testObj = createSimpleObj();
      expect(validator.execute(testObj), isNull);

      testObj.value1 = ",*[";
      testObj.value2 = 2;
      testObj.value3 = null;

      var invalidFields = {
        "value1": ["matches"],
        "value2": ["range"],
        "value3": ["notEmpty"]
      };

      expect(validator.execute(testObj).invalidFields, equals(invalidFields));
    });

    test("using schema", () {
      var obj = new TestValidator()
        ..value1 = "str"
        ..value2 = 10
        ..value3 = true;

      expect(obj.validate(), isNull);

      obj.value1 = ",*[";
      obj.value2 = 2;
      obj.value3 = null;

      var invalidFields = {
        "value1": ["matches"],
        "value2": ["range"],
        "value3": ["notEmpty"]
      };

      expect(obj.validate().invalidFields, equals(invalidFields));
    });
  });
}
