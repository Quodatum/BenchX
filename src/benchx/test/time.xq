(:~
 : tests for time function
 :)
import module namespace xm = 'apb.xmark.test' at "../xmark.xqm";

(:~ Function demonstrating a successful test. :)
declare %unit:test function unit:assert-success() {
  unit:assert(<a/>)
};
  
(:~ Function demonstrating a failure using unit:assert. :)
declare %unit:test function unit:assert-failure() {
  unit:assert((), 'Empty sequence.')
};
  
(:~ Function demonstrating a failure using unit:assert-equals. :)
declare %unit:test function unit:assert-equals-failure() {
  unit:assert-equals(4 + 5, 6)
};
  
(:~ Function demonstrating an unexpected success. :)
declare %unit:test("expected", "FORG0001") function unit:unexpected-success() {
  ()
};
  
(:~ Function demonstrating an expected failure. :)
declare %unit:test("expected", "FORG0001") function unit:expected-failure() {
  1 + <a/>
};
  
(:~ Function demonstrating the creation of a failure. :)
declare %unit:test function unit:failure() {
  unit:fail("Failure!")
};
  
(:~ Function demonstrating an error. :)
declare %unit:test function unit:error() {
  1 + <a/>
};
  
(:~ Skipping a test. :)
declare %unit:test %unit:ignore("Skipped!") function unit:skipped() {
  ()
};
 
(: run all tests :)
unit:test()