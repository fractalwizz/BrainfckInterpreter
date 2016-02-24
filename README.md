## BrainfckInterpreter
Interpreter for the Brainfck language written in Perl<br>
V0.8

### Disclaimer
Fractalwizz is not the author of any of the example programs.<br>
They are only provided to test the interpreter's functionality

### Module Dependencies
Modern::Perl<br>
Getopt::Std<br>
File::Basename

### Usage
perl bf.pl [options] inputFile<br>
  -f:         Program Flat Version Output<br>
  -s:         Tape Cell Storage (255 overflow) (default: unlimited)<br>
  -s [int]:   Tape Length (default: unlimited)<br>
  inputFile: path of file
  
ie:<br>
perl bf.pl ./Examples/hellobig.bf<br>
perl bf.pl -f cat.bf<br>
perl bf.pl -l 8 jabh.bf

### Features
Brainfck Esoteric Programming Language<br>
Supports any text file with valid brainfck code<br>
Can reformat input program file (removes comments, spacing, etc..) (Cmd parameter)<br>
Define Memory Tape Length Constraint (Cmd parameter)<br>
Define Memory Tape Cell Storage Constraint (Cmd parameter)

### TODO
Optimization / Restructure of subroutine code<br>
Cmd parameter for trace information of each step<br>
Cmd parameter for advanced trace (diagram + pointer visualization)

### License
MIT License<br>
(c) 2016 Fractalwizz<br>
http://github.com/fractalwizz/BrainfckInterpreter