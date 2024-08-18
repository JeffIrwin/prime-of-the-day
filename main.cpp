
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

#include "date.h"

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
	//for (int i = nstr - 1; i >= 0; i--)
	for (int i = 1; i <= nstr; i++)
	{
		str = str_bare[nstr - i] + str;
		if (i % 3 == 0 && i < nstr)
			str = "," + str;
	}
	return str;
}

int main()
{
	//// the 100,000'th prime number is 1,299,709 and can be calculated here in
	//// about 13 seconds.  if i continue posting every day, it will take roughly
	//// 300 years to get to that point, so there aren't any concerns about run
	//// time or size_t overflow.
	//std::cout << nth_prime_number(100000) << "\n";

	//// TODO: split into unit tests.  also cover nth_prime_number()
	//std::cerr << comma_delim(1)   << "\n";
	//std::cerr << comma_delim(12)  << "\n";
	//std::cerr << comma_delim(123) << "\n";

	//std::cerr << comma_delim(1234)   << "\n";
	//std::cerr << comma_delim(12345)  << "\n";
	//std::cerr << comma_delim(123456) << "\n";

	//std::cerr << comma_delim(1234567) << "\n";
	//std::cerr << comma_delim(12345678) << "\n";
	//std::cerr << comma_delim(123456789) << "\n";

	//std::cerr << comma_delim(1234567891) << "\n";
	//std::cerr << comma_delim(12345678912) << "\n";
	//std::cerr << comma_delim(123456789123) << "\n";

	using namespace date;
	using namespace std::chrono;

	auto today = floor<days>(system_clock::now());

	// this is the day before i started posting.  post 2 on the first day, 3 and
	// the second, ...
	auto day_zero = 2024_y/8/16;
	//auto day_zero = 2021_y/4/6;
	//auto day_zero = 1800_y/4/6;

	std::cerr << "zero  = " << day_zero << '\n';
	std::cerr << "today = " << today    << '\n';

	auto days = (sys_days{today} - sys_days{day_zero}).count();
	std::cerr << "days = " << days << " days\n";

	// log nothing else after this.  the run.sh script will pickup the last line
	// of stdout for the text payload
	std::cout << comma_delim(nth_prime_number(days)) << "\n";

	return 0;
}

