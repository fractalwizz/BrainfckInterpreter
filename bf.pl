#!/usr/bin/perl
use Modern::Perl;
use Getopt::Std;
use File::Basename;
no warnings 'experimental::smartmatch';

my @prog;
my @tape;
my %opt = ();

# cmd parameters
getopts('fsl:dp', \%opt);
if (not defined $opt{l}) { $opt{l} = 0; }

my $buffer = "";
my $bail = 1;
my $memptr = 0;
my $proptr = 0;

my $file = shift;

if (!$file) {
    my $prog = basename($0);
    
    print "USAGE\n";
    print "  $prog [options] textfile OR progtext\n\n";
    print "DESCRIPTION\n";
    print "  Brainfck Interpreter written in Perl\n\n";
    print "OPTIONS\n";
    print "  -f        Produce Flat version of input program\n";
    print "  -d        Debug Statistics File Output (disabled with -p)\n";
    print "  -s        Tape Cell Storage cap at 255 (overflow) (default: unlimited)\n";
    print "  -l [int]  Tape Length (default: unlimited)\n";
	print "  -p        BF-to-Perl Conversion + execution\n\n";
    print "OPERANDS\n";
    print "  textfile  path to input text file\n";
    print "  or\n";
    print "  progtext  Literal String of Program Instructions\n\n";
    print "FILES\n";
    print "  Output files (-f,-s,...) written to current directory\n";
    print "  Flat (-f) filename is textfile-flat.bf\n";
    print "  DEBUG (-d) filename is textfile-debug.out\n";
	print "  Perl (-p) filename is textfile-perl.pl\n\n";
    print "EXAMPLES\n";
    print "  $prog ./Examples/cat.bf\n";
    print "  $prog -f triangle.bf\n";
    print "  $prog -s -p -l 20 one.bf\n";
    print "  $prog -d \",[.,]\"\n";
    
    exit(1);
}

if ($opt{d} && !$opt{p}) {
    my $fil = $file;
    if ($fil =~ m/[<>\[\]]/) { $fil = "cmdout.bf"; }
    
    $fil =~ /(\S+)\./;
    $fil = $1 . "-debug.out";
    
    open (DEBUG, '>', $fil) or die ("Can't create $fil: $!\n");
    print DEBUG "DEBUG enabled\n";
}

@prog = ($file =~ m/[<>\[\]]/) ? convert($file) : reduce($file);
if ($opt{d} && !$opt{p}) { print DEBUG "Program Array Initialized\n"; }

if ($opt{f}) { outprog($file); }

if ($opt{p}) {
	transcode($file);
	exit(0);
}

while ($bail) {
    if ($opt{d}) {
        print DEBUG "\nproptr: $proptr ";
        print DEBUG "memptr: $memptr ";
        print DEBUG "tapeval: ";
        print DEBUG (defined $tape[$memptr]) ? $tape[$memptr] : "null";
        print DEBUG "\n";
    }
    
    # termination condition
    if ($proptr >= @prog) { 
        if ($opt{d}) {
            print DEBUG "Execution Terminated: EOF\n";
            close (DEBUG);
        }
        
        $bail--;
        next;
    }
    
    my $char = $prog[$proptr];
    if ($opt{d}) { print DEBUG "char: $char op: "; }
    
    for ($char) {
        when ('>') { shiftright(); }
        when ('<') { shiftleft();  }
        when ('+') { increment();  }
        when ('-') { decrement();  }
        when (',') { input();      }
        when ('.') { output();     }
        when ('[') { loopstart();  }
        when (']') { loopend();    }
    }
    
    $proptr++;
}

#==================SUBROUTINES==========================

#----------------------------
#--------Instructions--------
#----------------------------

##\
 # Shifts memptr right
 #/
sub shiftright {
    if ($opt{d}) { print DEBUG "memptr-->: $memptr=>"; }
    
    $memptr++;
    if ($opt{l} && $memptr == $opt{l}) { $memptr = 0; }
    
    if ($opt{d}) { print DEBUG "$memptr\n"; }
}

##\
 # Shifts memptr left unless at the left end of tape
 #/
sub shiftleft {
    if ($opt{d}) { print DEBUG "<--memptr: $memptr=>"; }
    
    if ($memptr == 0) {
        if ($opt{l}) { $memptr = $opt{l} - 1; }
    } else {
        $memptr--;
    }
    
    if ($opt{d}) { print DEBUG "$memptr\n"; }
}

##\
 # Increments value of cell at memptr
 #/
sub increment {
    if ($opt{d}) {
        print DEBUG "++ Cell #$memptr: ";
        if (defined $tape[$memptr]) { print DEBUG "$tape[$memptr]=>"; }
    }
    
    $tape[$memptr]++;
    if ($opt{s} && $tape[$memptr] > 255) { $tape[$memptr] = 0; }
    
    if ($opt{d}) { print DEBUG "$tape[$memptr]\n"; }
}

##\
 # Decrements value of cell at memptr
 #/
sub decrement {
    if ($opt{d}) {
        print DEBUG "-- Cell #$memptr: ";
        if (defined $tape[$memptr]) { print DEBUG "$tape[$memptr]=>"; }
    }
    
    $tape[$memptr]--;
    if ($opt{s} && $tape[$memptr] < 0) { $tape[$memptr] = 255; }
    
    if ($opt{d}) { print DEBUG "$tape[$memptr]\n"; }
}

##\
 # Requests input from user
 # Stores input in buffer, saves first char to cell at memptr
 #/
sub input {
    my $val;

    if ($buffer) {
        if ($opt{d}) { print DEBUG "Buffered Input: "; }
    
        $val = ord substr($buffer, 0, 1);
        $tape[$memptr] = $val;
        $buffer = substr($buffer, 1);
    } else {
        if ($opt{d}) { print DEBUG "User Input: "; }
    
        print "?";
        $val = <>;

        if (not defined $val) {
            print "ERROR: input not found";
        } else {
            $buffer = $val . chr(0);
            $val = ord substr($buffer, 0, 1);
            $buffer = substr($buffer, 1);

            $tape[$memptr] = $val;
        }
    }
    
    if ($opt{d}) { print DEBUG "$tape[$memptr]\n"; }
}

##\
 # Prints ASCII value of cell at memptr
 #/
sub output {
    if ($opt{d}) { printf DEBUG "Output: %s\n", chr $tape[$memptr]; }
    print chr $tape[$memptr];
}

##\
 # Skip loop to matching right bracket if cell at memptr is zero
 #/
sub loopstart {
    if ($opt{d}) { print DEBUG "Loop Start(?): \n"; }
    
    if (!$tape[$memptr]) {
        if ($opt{d}) { print DEBUG "Skipping Loop: "; }
        
        my $count = 1;
        my $cnt = $proptr;

        for my $i ($proptr + 1 .. @prog - 1) {
            if ($opt{d}) { print DEBUG $prog[$i]; }
            
            if ($prog[$i] ~~ '[') { $count++; }
            if ($prog[$i] ~~ ']') { $count--; }
            $cnt++;

            if ($count == 0) { last; }
        }

        $proptr = $cnt;
        
        if ($opt{d}) { print DEBUG "\n"; }
    }
}

##\
 # Backtrack to matching left bracket if cell at memptr is not zero
 #/
sub loopend {
    my $gres = "";
    if ($opt{d}) { print DEBUG "Loop End(?): \n"; }

    if ($tape[$memptr]) {
        if ($opt{d}) { print DEBUG "Back to Start: "; }
        
        my $count = 1;
        my $cnt = $proptr - 1;

        while ($cnt > 0) {
            if ($opt{d}) { $gres = $prog[$cnt] . $gres; }
        
            if ($prog[$cnt] ~~ ']') { $count++; }
            if ($prog[$cnt] ~~ '[') { $count--; }

            if ($count == 0) { last; }
            $cnt--;
        }

        $proptr = $cnt;
        
        if ($opt{d}) { print DEBUG "$gres\n"; }
    }
}

#----------------------------
#-----------Util-------------
#----------------------------

##\
 # Converts BF code to Perl Code
 # Then executes created perl file
 #
 # param: $file: name of input file
 #/
sub transcode {
	my ($file) = @_;
	my $gorp;
	
	# define hash sets
	my %hash = ();
	my %temp = (
		','=>'$t[$mptr] = ord(getc);',
		'.'=>'print chr($t[$mptr]);',
		'['=>'while($t[$mptr]) {',
		']'=>'}',
	);
	my %defepat = (
		'>'=>'$mptr++;',
		'<'=>'$mptr--;',
	);
	my %defcell = (
		'+'=>'$t[$mptr]++;',
		'-'=>'$t[$mptr]--;',
	);
	my %epat = (
		'>'=>'$mptr++;'."\n".'if ($mptr == '.$opt{l}.') { $mptr = 0; }',
		'<'=>'$mptr = ($mptr == 0) ? '.($opt{l} - 1).' : $mptr - 1;',
	);
	my %cell = (
		'+'=>'$t[$mptr]++;'."\n".'if ($t[$mptr] > 255) { $t[$mptr] = 0; }',
		'-'=>'$t[$mptr]--;'."\n".'if ($t[$mptr] < 0) { $t[$mptr] = 255; }',
	);
	
	# convert program array to string
	for (@prog) { $gorp .= $_; }
	
	# construct custom hash translation table
	%hash = (%hash, %temp);
	if ($opt{l}) { %hash = (%hash, %epat); }
	if ($opt{s}) { %hash = (%hash, %cell); }
	unless (exists($hash{'>'})) { %hash = (%hash, %defepat); }
	unless (exists($hash{'+'})) { %hash = (%hash, %defcell); }
	
	# translate
	$gorp =~ s/(.)/$hash{$1}\n/g;
	
	if ($file =~ m/[<>\[\]]/) { $file = "cmdout.bf"; }
	$file =~ /(\S+)\./;
	$file = $1 . "-perl.pl";
	
	# output to file
	open (OUT, ">", $file) or die ("DERP: $!");
	print OUT $gorp;
	close (OUT);
	
	# execute created file
	system ("perl $file");
}

##\
 # Saves contents of program array to file
 #
 # param: $file: name of input file
 # param: $prog: name of program array
 #/
sub outprog {
    my ($file) = @_;
    if ($file =~ m/[<>\[\]]/) { $file = "cmdout.bf"; }
    
    $file =~ s/(\S+)\..*$/$1/;
    open (OUT, '>', "$file-flat.bf") or die ("Cannot open $file-flat.bf: $!\n");
    
    for my $i (@prog) { print OUT $i; }
    
    close (OUT);
}

##\
 # Collects all program instructions into array
 #
 # param: $file: name of input file
 #
 # return: @out: array of program instructions
 #/
sub reduce {
    my ($file) = @_;
    my @out;
    
    open (FILE, '<', $file) or die("Can't open $file: $!\n");
    while (<FILE>) { push(@out, convert($_)); }
    close (FILE);
    
    return @out;
}

##\
 # Converts Instruction String into array
 #
 # param: $file: string containing program Instructions
 #
 # return: $out: array of program instructions
 #/
sub convert {
    my ($file) = @_;
    my @out;
    
    for (0 .. length($file) - 1) {
        my $char = substr($file, 0, 1);
        $file = substr($file, 1);
            
        if ($char =~ m/[\>\<\+\-\.\,\[\]]/) { push(@out, $char); }
    }
    
    return @out;
}