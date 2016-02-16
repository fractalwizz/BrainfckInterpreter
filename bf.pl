#!/usr/bin/perl
use Modern::Perl;

my @prog;
my @tape;

my $buffer = "";
my $bail = 1;
my $memptr = 0;
my $proptr = 0;

my $file = shift;
@prog = reduce($file);

outprog($file, \@prog); # use for debug

while ($bail) {
    # termination condition
    if ($proptr == @prog) { $bail--; next; }
    
    my $char = $prog[$proptr];
    
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
sub shiftright { $memptr++; }

##\
 # Shifts memptr left unless at the left end of tape
 #/
sub shiftleft { unless ($memptr == 0) { $memptr--; } }

##\
 # Increments value of cell at memptr
 #/
sub increment { $tape[$memptr]++; }

##\
 # Decrements value of cell at memptr
 #/
sub decrement { $tape[$memptr]--; }

##\
 # Requests input from user
 # Stores input in buffer, saves first char to cell at memptr
 #/
sub input {
    my $val;

    if ($buffer) {
        $val = ord substr($buffer, 0, 1);
        $tape[$memptr] = $val;
        $buffer = substr($buffer, 1);
    } else {
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
}

##\
 # Prints ASCII value of cell at memptr
 #/
sub output { print chr $tape[$memptr]; }

##\
 # Skip loop to matching right bracket if cell at memptr is zero
 #/
sub loopstart {
    if (!$tape[$memptr]) {
        my $count = 1;
        my $cnt = $proptr;

        for my $i($proptr + 1 .. @prog - 1) {
            if ($prog[$i] ~~ '[') { $count++; }
            if ($prog[$i] ~~ ']') { $count--; }
            $cnt++;

            if ($count == 0) { last; }
        }

        $proptr = $cnt;
    }
}

##\
 # Backtrack to matching left bracket if cell at memptr is not zero
 #/
sub loopend {
    if ($tape[$memptr]) {
        my $count = 1;
        my $cnt = $proptr - 1;

        while ($cnt > 0) {
            if ($prog[$cnt] ~~ ']') { $count++; }
            if ($prog[$cnt] ~~ '[') { $count--; }

            if ($count == 0) { last; }
            $cnt--;
        }

        $proptr = $cnt;
    }
}

#----------------------------
#-----------Util-------------
#----------------------------

##\
 # Saves contents of program array to file
 #
 # param: $file: name of input file
 # param: $prog: name of program array
 #/
sub outprog {
    my ($file, $prog) = @_;
    
    $file =~ s/(\S+)\..*$/$1/;
    $file .=  "a";
    open(OUT, '>', "$file.bf") or die ("Cannot open $file.bf: $!\n");
    
    for my $i(@$prog) {
        print OUT $i;
    }
    
    close(OUT);
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
    
    open(FILE, '<', $file) or die("Can't open $file: $!\n");
    
    while (<FILE>) {
        my $str = $_;
        
        for (0 .. length($_) - 1) {
            my $char = substr($str, 0, 1);
            $str = substr($str, 1); 
            
            if ($char =~ m/[\>\<\+\-\.\,\[\]]/) { push(@out, $char); }
        }
    }
    
    return @out;
}