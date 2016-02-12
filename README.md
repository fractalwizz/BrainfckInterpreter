## BrainfckInterpreter
Interpreter for the Brainfuck language written in Perl<br>
V0.8

### Disclaimer
Fractalwizz is not the author of any of the example programs.<br>
They are only provided to test the interpreter's functionality

### Module Dependencies
Modern::Perl

### Usage
perl bf.pl inputFile<br>
  inputFile: path of image<br>
  
ie:<br>
perl bf.pl ./Examples/hellobig.bf<br>
perl bf.pl cat.bf

### Features
Brainfuck Esoteric Programming Language<br>
Supports any text file with valid brainfuck code<br>
Can reformat input program file (removes comments, spacing, etc..)<br>

### TODO
Optimization / Restructure of subroutine code
Cmd parameter for memory cell storage (overflow 255->0 or unlimited)
Cmd parameter for memory tape length (default: unlimited)
Cmd parameter for reformatting input program file (saving to separate file)
Cmd parameter for trace information of each step
Cmd parameter for advanced trace (diagram + pointer visualization)

### License
MIT License<br>
(c) 2016 Fractalwizz<br>
http://github.com/fractalwizz/BrainfckInterpreter