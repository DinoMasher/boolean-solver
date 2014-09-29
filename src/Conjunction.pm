#!/usr/bin/perl -w

#package to represent boolean expressions consisting of AND operations and any number of variables
#it is assumed variables are strings, and negations are represented by adding a tilde ~ in front of a variable
#"0" and "1" are the logical values 0 and 1 respectively
use strict;
use warnings;
package Conjunction;
our $not_op = "~"; #global variable representing the logical negation


#each instance is an array of boolean variables, representing a conjunction
sub new {
	my ($class) = @_;
	my $self = ["1"];	#initialization at 1
	
	bless $self, $class;
	return $self;
}

#set expression from an array
sub setFromArray {
	my ($self, $array_ref) = @_;
	my @variables = @$array_ref;
	
	foreach my $variable (@variables) {
		#print $variable, "\n";
		if (not($self->add($variable))) {
			last;
		}
	}
	return $self;
}


#set expression from a string containing a list of variables separated by spaces
sub setFromString {
	my ($self, $string) = @_;
	my @array;
	@array = split(' ', $string);
	#@$self = @array;
	$self->setFromArray(\@array);
	return $self;
}

#add an element to the conjunction (string)
#returns 0 if simplified to 0, else 1
sub add {
	my ($self, $variable) = @_;
	#print $variable, "\n";
	$variable =~ /^(${not_op}*)(.+)$/;	#analyse variable to simplify the negation operator
	my $negation = length($1) % 2;
	my $orig_variable = $2;
	$variable = ($not_op x $negation) . $orig_variable;
	my $neg_variable = ($not_op x (($negation + 1) % 2)) . $orig_variable;
	if ($variable ne "1") {	#skip if element is 1
		if ($variable eq "0") {
			@$self = ("0");	#overwrite if element is 0
			return 0;
		} else {
			if (not($self->has($variable))) {	
				if (not($self->has($neg_variable))) {
					if ((scalar(@$self) == 1) and (@$self[0] eq "1")) {
						@$self[0] = $variable;
					} else {
						push(@$self, $variable);	#no variable with this name found
					}
				} else {
					@$self = ("0");	#negation is already present, we overwrite the array with "0"
					return 0;
				}
			}
		}
	}
	return 1;
}

#merge self and another conjunction
sub and {
	my ($self, $other) = @_;
	foreach my $variable (@$other) {
		if (not $self->add($variable)) {
			last;
		}
	}
	return $self;
}

#find if a variable is in an expression
sub has {
	my ($self, $variable) = @_;
	#create an anonymous hash to search an element faster
	if (exists {map { $_ => 1 } @$self}->{$variable}) {
		return 1;
	} else {
		return 0;
	}
}

#compare 2 conjunctions, ignoring the order of variables in the expression
sub equal {
	my ($self, $other) = @_;
	if (scalar(@$self) == scalar(@$other)) {
		foreach my $variable (@$other) {
			if (not $self->has($variable)) {
				return 0;
			}
		}
	} else {
		return 0;
	}
	return 1;
}

#using a hash to evaluate an expression
#the hash contains variables as keys, and values are either 0 for false, or anything else for true
#returns 0 or 1 if all the variables have a value in the hash, or another conjunction if not all variables are present 
sub evaluate {
	my ($self, $hash_ref) = @_;
	my %values = %$hash_ref;
	my $other = Conjunction->new();
	
	foreach my $variable (@$self) {
		#test if the variable is a negation
		if ($variable =~ /^${not_op}(.+)$/) {
			my $orig_variable = $1;
			if (exists $values{$orig_variable}) {
				if ($values{$orig_variable}) {
					$other->setFromString("0");	#evaluate to 0
				} else {
					next;
				}
			} else {
				$other->add($variable);	#variable not present in hash, add it to the result
			}
		} else {
			if (exists $values{$variable}) {
				if (not $values{$variable}) {
					$other->setFromString("0");	#evaluate to 0
				} else {
					next;
				}
			} else {
				$other->add($variable);	#variable not present in hash, add it to the result
			}
		}
	}
	return $other;
}



1;