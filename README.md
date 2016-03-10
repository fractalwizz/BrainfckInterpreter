## BrainfckInterpreter
Interpreter for the Brainfck language written in Perl<br>
V0.93

### Disclaimer
Fractalwizz is not the author of any of the example programs.<br>
They are only provided to test the interpreter's functionality

### Module Dependencies
Modern::Perl<br>
Getopt::Std<br>
File::Basename

### Usage
perl bf.pl [options] inputFile<br>
  -f:        Program Flat Version Output<br>
  -d:        Debug Statistics File Output<br>
  -s:        Tape Cell Storage (255 overflow) (default: unlimited)<br>
  -l [int]:  Tape Length (default: unlimited)<br>
  inputFile: path of file
  
ie:<br>
perl bf.pl ./Examples/hellobig.bf<br>
perl bf.pl -f cat.bf<br>
perl bf.pl -l 8 jabh.bf<br>
perl bf.pl -d -s ",[.,]"

### Features
Brainfck Esoteric Programming Language<br>
Supports any text file with valid brainfck code<br>
Can reformat input program file (removes comments, spacing, etc..) (Cmd parameter)<br>
Debug Statistic Information for each step (Cmd parameter)<br>
Define Memory Tape Length Constraint (Cmd parameter)<br>
Define Memory Tape Cell Storage Constraint (Cmd parameter)

### TODO
Cmd parameter for advanced trace (diagram + pointer visualization)

### License
MIT License<br>
(c) 2016 Fractalwizz<br>
http://github.com/fractalwizz/BrainfckInterpreter