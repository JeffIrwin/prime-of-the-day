
#include <chrono>
#include <iostream>
#include <stdio.h>
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

int main()
{
	//// the 100,000'th prime number is 1,299,709 and can be calculated here in
	//// about 13 seconds.  if i continue posting every day, it will take around
	//// 300 years to get to that point, so there aren't any concerns about run
	//// time or size_t overflow.
	//std::cout << nth_prime_number(100000) << "\n";

	using namespace date;
	using namespace std::chrono;

	auto today = floor<days>(system_clock::now());

	// this is the day before i started posting.  post 2 on the first day, 3 and
	// the second, ...
	auto day_zero = 2024_y/8/16;
	//auto day_zero = 2024_y/8/11;

	// TODO: cerr?  cout is hidden by run.sh
	std::cout << "zero  = " << day_zero << '\n';
	std::cout << "today = " << today    << '\n';

	auto days = (sys_days{today} - sys_days{day_zero}).count();
	std::cout << "days = " << days << " days\n";

	// log nothing else after this.  the run.sh script will pickup the last line
	// of stdout for the text payload
	//
	// TODO: comma thousands separator. fmtlib?
	std::cout << nth_prime_number(days) << "\n";

	return 0;
}

