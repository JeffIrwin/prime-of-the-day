
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <vector>

#include "date.h"

size_t nth_prime_number(size_t n)
{
	// Return the nth prime.  To be clear about off-by-one errors,
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
	/*
	std::cout << nth_prime_number( 0) << "\n";
	std::cout << nth_prime_number( 1) << "\n";
	std::cout << nth_prime_number( 2) << "\n";
	std::cout << nth_prime_number(10) << "\n";

	for (size_t i = 0; i < 100; i++)
		std::cout << nth_prime_number(i) << "\n";

	//std::cout << nth_prime_number(90000) << "\n";
	//std::cout << nth_prime_number(1000000) << "\n";
	*/

	//// can't get c++20 working :(
	//using namespace std::chrono;
	//using namespace std;
	//auto x = 2012y/1/24;
	//auto y = 2013y/1/8;
	////cout << x << '\n';
	////cout << y << '\n';
	////cout << "difference = " << sys_days{y} - sys_days{x} << 'n';
	//cout << "difference = " << int(sys_days{y} - sys_days{x}) << 'n';

	using namespace date;
	//using namespace std;

	//auto x = 2012_y/1/24;
	//auto y = 2013_y/1/8;
	//cout << x << '\n';
	//cout << y << '\n';
	//cout << "difference = " << (sys_days{y} - sys_days{x}).count() << " days\n";

	auto today = floor<days>(std::chrono::system_clock::now());

	auto day_zero = 2024_y/8/17;
	//auto day_zero = 2024_y/8/11;

	std::cout << "zero  = " << day_zero << '\n';
	std::cout << "today = " << today    << '\n';

	auto days = (sys_days{today} - sys_days{day_zero}).count();
	std::cout << "days = " << days << " days\n";

	// Log nothing else after this.  The run.sh script will pickup the last line
	// of stdout for the text payload
	std::cout << nth_prime_number(days) << "\n";

	return 0;
}

