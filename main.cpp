
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

#include "state.h"

// ANSI escape codes
const std::string RED    = "\033[31m";
const std::string YELLOW = "\033[33m";
const std::string RESET  = "\033[0m";

size_t nth_prime_number(size_t n)
{
	// return the nth prime.  to be clear about off-by-one errors,
	// nth_prime_number(1) returns 2.
	if (n <= 0)
		return 2;

	std::vector<size_t> primes;
	primes.push_back(2);

	size_t num = 3;

	// keep generating primes until we get to the nth one
	while (primes.size() < n)
	{
		// check if num is divisible by any prime before it
		bool is_prime = true;
		for (size_t ip = 0; ip < primes.size(); ip++)
			if (num % primes[ip] == 0)
			{
				is_prime = false;
				break;
			}
		if (is_prime)
			primes.push_back(num);

		num += 2;
	}
	return primes[n-1];
}

std::string comma_delim(size_t n)
{
	// convert a number to a string and add commas as thousands separators.
	// could use fmtlib instead
	std::string str_bare = std::to_string(n);
	size_t nstr = str_bare.size();

	//std::cerr << "str_bare len = " << nstr << "\n";
	if (nstr <= 4)
		// stylistic preference: don't dangle a single digit for 4 digit numbers
		return str_bare;

	// should use str builder but these aren't very big
	std::string str = "";
	for (int i = 1; i <= nstr; i++)
	{
		str = str_bare[nstr - i] + str;
		if (i % 3 == 0 && i < nstr)
			str = "," + str;
	}
	return str;
}

size_t unit_tests()
{
	size_t nfail = 0;

	// TODO: refactor as bool array

	if (comma_delim(1) != "1") nfail++;
	if (comma_delim(12) != "12") nfail++;
	if (comma_delim(123) != "123") nfail++;

	if (comma_delim(1234) != "1234") nfail++;
	if (comma_delim(12345) != "12,345") nfail++;
	if (comma_delim(123456) != "123,456") nfail++;

	if (comma_delim(1234567) != "1,234,567") nfail++;
	if (comma_delim(12345678) != "12,345,678") nfail++;
	if (comma_delim(123456789) != "123,456,789") nfail++;

	if (comma_delim(1234567891) != "1,234,567,891") nfail++;
	if (comma_delim(12345678912) != "12,345,678,912") nfail++;
	if (comma_delim(123456789123) != "123,456,789,123") nfail++;

	// TODO: log if failure.  run during "push" ci/cd (but not "schedule")

	// TODO: also cover nth_prime_number()

	// TODO: log green if no fails
	if (nfail != 0)
		std::cerr
			<< RED
			<< "Error: " << nfail << " unit test(s) failed\n"
			<< RESET;

	return nfail;
}

int main(int argc, char* argv[])
{
	bool test = false;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		//std::cerr << "arg = " << arg << "\n";
		if (arg == "--test")
			test = true;
		else
			std::cerr
				<< YELLOW
				<< "Warning: bad command line arg \"" << arg << "\"\n"
				<< RESET;
	}

	if (test)
		return unit_tests();

	//// the 100,000'th prime number is 1,299,709 and can be calculated here in
	//// about 13 seconds.  if i continue posting every day, it will take roughly
	//// 300 years to get to that point, so there aren't any concerns about run
	//// time or size_t overflow.
	//std::cout << nth_prime_number(100000) << "\n";

	auto days = PRIME_STATE_COUNT;
	std::cerr << "days = " << days << " days\n";

	// log nothing else after this.  the run.sh script will pickup the last line
	// of stdout for the text payload
	std::cout << comma_delim(nth_prime_number(days)) << "\n";

	return 0;
}

