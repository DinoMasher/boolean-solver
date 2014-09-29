#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More;  
use Conjunction;

#instantiation tests
{
	my $expr = Conjunction->new();
	ok(defined ($expr), "new() returned something");
	ok($expr->isa('Conjunction'), "   and it is the right class");
}

#add an element
{
	my $expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	my @array = qw(a[0] b[1] ~c[0]);
	my @array2 = qw(a[0] b[1] ~c[0] d[2]);
	$expr->setFromArray(\@array);
	#print @$expr, "\n";
	$expr2->setFromArray(\@array2);
	#print @$expr2, "\n";
	$expr->add("d[2]");
	is_deeply($expr, $expr2, "adding an element, no simplification");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	#print @$expr, "\n";
	$expr2->setFromArray(\@array2);
	#print @$expr2, "\n";
	$expr->add("b[1]");
	is_deeply($expr, $expr2, "adding an element already present");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr->add("~~b[1]");
	is_deeply($expr, $expr2, "adding an element already present (with negation simplification");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(0);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr->add("c[0]");
	is_deeply($expr, $expr2, "adding an element: simplification to 0");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(0);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr->add("0");
	is_deeply($expr, $expr2, "adding an element (0): simplification to 0");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr->add("1");
	is_deeply($expr, $expr2, "adding an element (1): no change");
}

#set an expression
{
	my $expr = Conjunction->new();
	my @array = qw(a ~~b ~c);
	#print @array, "\n";
	$expr->setFromArray(\@array);
	#print @$expr, "\n";
	$array[1] = "b";
	#print @array, "\n";
	is_deeply($expr, \@array, "setting object from an array");
}
{
	my $expr = Conjunction->new();
	my @array = qw(~a ~b c);
	$expr->setFromString("~~~a ~b c");
	is_deeply($expr, \@array, "setting object from a string");
}

#evaluate an expression (initialization)
{
	my $expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	$expr2->setFromString("1");
	my %values = ();
	my $value = $expr->evaluate(\%values);
	is_deeply($value, $expr2, "default expression is 1");
}
#evaluate an expression
{
	my $expr = Conjunction->new();
	my @array = qw(a b ~c);
	my %values = ("a" => 0, "b" => 0, "c" => 1);
	my $value = 0;
	$expr->setFromArray(\@array);
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and b and (not c) for (a,b,c) = (0,0,0)");
	$values{"a"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and b and (not c) for (a,b,c) = (1,0,1)");
	$values{"b"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and b and (not c) for (a,b,c) = (1,1,1)");
	$values{"c"} = 0;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [1], "a and b and (not c) for (a,b,c) = (1,1,0)");

	$expr = Conjunction->new();
	@array = qw(a ~~b ~c);
	%values = ("a" => 0, "b" => 0, "c" => 1);
	$value = 0;
	$expr->setFromArray(\@array);
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not c) for (a,b,c) = (0,0,0)");
	$values{"a"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not c) for (a,b,c) = (1,0,1)");
	$values{"b"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not c) for (a,b,c) = (1,1,1)");
	$values{"c"} = 0;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [1], "a and (not not b) and (not c) for (a,b,c) = (1,1,0)");

	$expr = Conjunction->new();
	@array = qw(a ~~b ~~~c);
	%values = ("a" => 0, "b" => 0, "c" => 1);
	$value = 0;
	$expr->setFromArray(\@array);
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not not not c) for (a,b,c) = (0,0,0)");
	$values{"a"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not not not c) for (a,b,c) = (1,0,1)");
	$values{"b"} = 1;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "a and (not not b) and (not not not c) for (a,b,c) = (1,1,1)");
	$values{"c"} = 0;
	$value = $expr->evaluate(\%values);
	is_deeply($value, [1], "a and (not not b) and (not not not c) for (a,b,c) = (1,1,0)");
	
	#expression simplification when not all variables have a value
	$expr = Conjunction->new();
	@array = qw(~a b c);
	%values = ("b" => 0, "c" => 1);
	$value = 0;
	$expr->setFromArray(\@array);
	$value = $expr->evaluate(\%values);
	is_deeply($value, [0], "(not a) and b and c for (b,c) = (0,1)");
	
	$expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	@array = qw(~a b c);
	$expr->setFromArray(\@array);
	$expr2->setFromString("~a");
	%values = ("b" => 1, "c" => 1);
	$value = $expr->evaluate(\%values);
	is_deeply($value, $expr2, "(not a) and b and c for (b,c) = (1,1)");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(~a b c);
	$expr->setFromArray(\@array);
	$expr2->setFromString("~a c");
	%values = ("b" => 1);
	$value = $expr->evaluate(\%values);
	is_deeply($value, $expr2, "(not a) and b and c for b = 1");
}

#auto-simplification at instantiation
{
	my $expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	my @array = qw(a[0] b[1] a[0] ~c[0]);
	my @array2 = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is_deeply($expr, $expr2, "simplification of a[0] and b[1] and a[0] and ~c[0], removing one a[0]");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(a[0] b[1] c[0] ~c[0]);
	@array2 = qw(0);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is_deeply($expr, $expr2, "simplification of a[0] and b[1] and c[0] and ~c[0], to 0");
}


#test presence of an element
{
	my $expr = Conjunction->new();
	my @array = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	is($expr->has("d[2]"), 0, "test if element present");
	
	$expr = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	$expr->setFromArray(\@array);
	is($expr->has("b[1]"), 1, "test if element present");
}

#merge 2 conjunctions
{
	my $expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	my $expr3 = Conjunction->new();
	my @array = qw(a[0] b[1] ~c[0]);
	my @array2 = qw(a[2] b[0] ~c[1] d[2]);
	my @array3 = qw(a[0] b[1] ~c[0] a[2] b[0] ~c[1] d[2]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr3->setFromArray(\@array3);
	$expr->and($expr2);
	is_deeply($expr, $expr3, "merge 2 expressions");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	$expr3 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(a[0] b[0] ~c[1] d[2]);
	@array3 = qw(a[0] b[1] ~c[0] b[0] ~c[1] d[2]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr3->setFromArray(\@array3);
	$expr->and($expr2);
	is_deeply($expr, $expr3, "merge 2 expressions: simplification of a[0]");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	$expr3 = Conjunction->new();
	@array = qw(a[0] b[1] ~c[0]);
	@array2 = qw(~a[0] b[0] ~c[1] d[2]);
	@array3 = qw(0);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr3->setFromArray(\@array3);
	$expr->and($expr2);
	is_deeply($expr, $expr3, "merge 2 expressions: simplification to 0");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	$expr3 = Conjunction->new();
	@array = qw(1);
	@array2 = qw(a[0] b[0] ~c[1] d[2]);
	@array3 = qw(a[0] b[0] ~c[1] d[2]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	$expr3->setFromArray(\@array3);
	$expr->and($expr2);
	is_deeply($expr, $expr3, "merge 2 expressions, the first expression is 1");
}

#equality tests
{
	my $expr = Conjunction->new();
	my $expr2 = Conjunction->new();
	my @array = qw(~a[0] b[1] c[0]);
	my @array2 = qw(~a[0] b[1] c[0]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is($expr->equal($expr2), 1, "equality test, same order");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(~a[0] b[1] c[0]);
	@array2 = qw(~a[0] c[0] b[1]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is($expr->equal($expr2), 1, "equality test, different order");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(~a[0] b[1] c[0]);
	@array2 = qw(~a[0] c[0] ~b[1]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is($expr->equal($expr2), 0, "equality test, different expressions 1");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(~a[0] b[1] c[0]);
	@array2 = qw(~a[0] b[1] c[0] d[1]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is($expr->equal($expr2), 0, "equality test, different expressions 2");
	
	$expr = Conjunction->new();
	$expr2 = Conjunction->new();
	@array = qw(~a[0] b[1] c[0] d[1]);
	@array2 = qw(~a[0] b[1] c[0]);
	$expr->setFromArray(\@array);
	$expr2->setFromArray(\@array2);
	is($expr->equal($expr2), 0, "equality test, different expressions 3");
}

#print @array, "\n";
	#print @$expr, "\n";

done_testing();   # reached the end safely