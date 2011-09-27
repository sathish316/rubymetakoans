var assert = require('assert'),
    vows = require('vows'),
    zombie = require('zombie');

var triangleSolved = 'class TriangleError < StandardError;end; def triangle a, b, c; a,b,c = [a,b,c].sort; raise TriangleError if [a,b,c].any?{|side| side <= 0} || a+b <= c; [nil, :equilateral, :isosceles, :scalene][[a,b,c].uniq.count]; end;';

var koansWithAnswers = {
  "about_asserts": ["true", "true", "2", "2", "2"],
  "about_nil": ["true", "NoMethodError", "undefined method", "true", "\"\"", "\"nil\""],
  "about_objects": ["true", "true", "true", "true", "true", "\"123\"", "\"\"", "\"123\"", "\"nil\"", "Fixnum", "true", "0", "2", "4", "1", "3", "5", "201", "true", "true"],
  "about_arrays": ["Array", "0", "2", "[1, 2, 333]", ":peanut", ":peanut", ":jelly", ":jelly", ":jelly", ":butter", "[:peanut]", "[:peanut, :butter]", "[:and, :jelly]", "[:and, :jelly]", "[]", "[]", "nil", "Range", "[1,2,3,4,5]", "[1,2,3,4]", "[:peanut, :butter, :and]", "[:peanut, :butter]", "[:and, :jelly]", "[1, 2, :last]", ":last", "[1, 2]", "[:first, 1, 2]", ":first", "[1, 2]"],
  "about_array_assignment": ["[\"John\", \"Smith\"]", "\"John\"", "\"Smith\"", "\"John\"", "\"Smith\"", "\"John\"", "[\"Smith\",\"III\"]", "\"Cher\"", "nil", "[\"Willie\", \"Rae\"]", "\"Johnson\"", "\"John\"", "'Rob'", "'Roy'"],
  "about_hashes": ["Hash", "0", "2", "\"uno\"", "\"dos\"", "nil", "\"eins\"", "true", "true", "2", "true", "true", "Array", "2", "true", "true", "Array", "true", "54", "26", "true"],
  "about_strings": ["true", "true", "'He said, \"Go Away.\"'", "\"Don't\"", "true", "true", "true", "54", "53", "\"Hello, World\"", "\"Hello, \"", "\"World\"", "\"Hello, World\"", "\"Hello, \"", "\"Hello, World\"", "\"World\"", "\"Hello, World\"", "1", "2", "2", "\"\\\\'\"", "\"The value is 123\"", "'The value is \#{value}'", "\"The square root of 5 is 2.23606797749979\"", "\"let\"", "\"let\"", "97", "97", "true", "true", "\"Sausage\"", "\"Egg\"", "\"Cheese\"", "\"the\"", "\"rain\"", "\"in\"", "\"spain\"", "\"Now is the time\"", "true", "false"],
  "about_symbols": ["true", "true", "false", "true", "true", "true", ":catsAndDogs", "\"cats and dogs\"", "\"cats and dogs\"", "'It is raining cats and dogs.'", "false", "false", "false", "false", "NoMethodError", ":catsdogs"],
  "about_regular_expressions": ["Regexp", "\"match\"", "nil", "\"ab\"", "\"a\"", "\"bccc\"", "\"abb\"", "\"a\"", "\"\"", "\"a\"", "[\"cat\", \"bat\", \"rat\"]", "\"42\"", "\"42\"", "\"42\"", "\" \\t\\n\"", "\"variable_1\"", "\"variable_1\"", "\"abc\"", "\"the number is \"", "\"the number is \"", "\"space:\"", "\" = \"", "\"start\"", "nil", "\"end\"", "nil", "\"2\"", "\"42\"", "\"vines\"", "\"hahaha\"", "\"Gray\"", "\"James\"", "\"Gray, James\"", "\"Gray\"", "\"James\"", "\"James Gray\"", "\"Summer\"", "nil", "[\"one\", \"two\", \"three\"]", "\"one t-three\"", "\"one t-t\""],
  "about_methods": ["5", "5", "ArgumentError", "wrong number of arguments", "ArgumentError", "wrong number of arguments", ":default_value", "2", "[]", "[:one]", "[:one, :two]", ":return_value", ":return_value", "12", "12", "\"a secret\"", "NoMethodError", "private method `my_private_method' called ", "\"Fido\"", "NoMethodError"],
  "about_constants": ["\"nested\"", "\"top level\"", "\"nested\"", "\"nested\"", "4", "4", "2", "4"],
  "about_control_statements": [":true_value", ":true_value", ":true_value", ":false_value", "nil", ":true_value", ":false_value", ":true_value", ":false_value", ":false_value", "3628800", "3628800", "[1, 3, 5, 7, 9]", "\"FISH\"", "\"AND\"", "\"CHIPS\""],
  "about_true_and_false": [":true_stuff", ":false_stuff", ":false_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff"],
  "about_triangle_project": [triangleSolved],
  "about_exceptions": ["RuntimeError", "StandardError", "Exception", "Object", ":exception_handled", "true", "true", "\"Oops\"", ":exception_handled", "\"My Message\"", ":always_run", "MySpecialError"],
  "about_triangle_project_2": [triangleSolved],
  "about_iteration": ["6", "6", "6", "[11, 12, 13]", "[11, 12, 13]", "[2, 4, 6]", "[2, 4, 6]", "\"Clarence\"", "9", "24", "[11, 12, 13]", "[\"THIS\", \"IS\", \"A\", \"TEST\"]"],
  "about_blocks": ["3", "3", "\"Jim\"", "[:peanut, :butter, :and, :jelly]", ":with_block", ":no_block", ":modified_in_a_block", "11", "11", "\"JIM\"", "20", "11"],
  "about_sandwich_code": ["4", "\"test\\n\"", "4", "file_sandwich(file_name) do |file|;  while line = file.gets;    return line if line.match /e/;  end;end", "\"test\\n\"", "4"],
  "about_scoring_project": [ "(1..6).collect do |n|; score_for_number = 0; count = dice.select{|x| x==n }.count; extra = count % 3; score_for_number += (n==1)? 1000 : n*100 if count/3==1; score_for_number += extra*100 if n == 1; score_for_number += extra*50  if n == 5; score_for_number; end.inject(0){|n,t| n+t }"],
  "about_classes": ["Dog", "[]", "[\"@name\"]", "NoMethodError", "\"Fido\"",  "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "ArgumentError", "true", "@name", "fido", "\"Fido\"", "\"My dog is Fido\"", "\"<Dog named 'Fido'>\"", "\"123\"", "\"[1, 2, 3]\"", "\"STRING\"", "'\"STRING\"'"],
  "about_open_classes": ["\"WOOF\"", "\"HAPPY\"", "\"WOOF\"", "false", "true"],
  "about_dice_project": [ "class DiceSet; def roll number; @number = number; @values = nil; end; def values; return @values unless @values.nil?; @values ||= []; @number.times{ @values.push(rand(6).to_i+1) }; @values; end; end; "],
  "about_inheritance": ["true", "true", "\"Chico\"", ":happy", "NoMethodError", "\"yip\"", "\"WOOF\"", "\"WOOF, GROWL\"", "NoMethodError"],
  "about_modules": ["NoMethodError", "\"WOOF\"", "\"Fido\"", "\"Rover\"", ":in_object"],
  "about_scope": ["NameError", ":jims_dog", ":joes_dog", "true", "true", "true", "false", "true", "3.1416", "true", "true", "true", "true", "[\"Dog\"]", "0"],
  "about_message_passing": ["\"?\"", "downcase", "true", "true", "false", "[]", "[]", "[3, 4, nil, 6]", "[3, 4, nil, 6]", "NoMethodError", "NoMethodError", "\"Someone called foobar with <>\"", "\"Someone called foobaz with <1>\"", "\"Someone called sum with <1, 2, 3, 4, 5, 6>\"", "false", "\"Foo to you too\"", "\"Foo to you too\"", "NoMethodError", "true", "false"],
  "about_to_str": ["\"non-string-like\"", "TypeError", "\"string-like\"", "false", "false", "true"],
}
var buildTestScripts = function(){
  var scripts = {}
  for (var koanName in koansWithAnswers) {
    if (koansWithAnswers.hasOwnProperty(koanName)) {
      var answers = koansWithAnswers[koanName];
      var url = "http://localhost:4567/?koan="+koanName;
      scripts['visits '+koanName] = {
        topic: function(url){ return function(){
          var zb = new zombie.Browser({debug: true})
          zb.visit(url, this.callback);
        };}(url),
        'and enters the correct values': {
          topic: function(koanName, answers, url){ return function(browser){
            if(answers.join().indexOf('<') > -1){
              // contains '<' character illegal to jsdom
              // so we must skip inputting values and visit URL directly
              var answerComponents = ''
              for(var i=0; i<answers.length; i++) answerComponents += "&input[]="+encodeURIComponent(answers[i]);
              url = url + answerComponents;
              browser.visit(url, this.callback);
            } else {
              var koanNameElement = browser.querySelector(":input[name=koan]");
              assert.equal(koanNameElement.value, koanName);
              for(var i=0; i<answers.length; i++) {
                browser.fill(".koanInput:eq("+(i)+")", answers[i]);
                // browser.document.getElementsByClassName('koanInput').item(i).innerHTML = answers[i];
              }
              browser.pressButton(":input[type=submit]", this.callback);
            }
          }; }(koanName, answers, url),
          'heightens my awareness': function(err, browser, status){
            assert.matches(browser.html(), /has heightened your awareness/);
          }
        }
      };
    }
  }
  return scripts;
}
vows.describe('Google').addBatch({
  'Given a headless browser': buildTestScripts()
}).run();
