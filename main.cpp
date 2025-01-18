
#include <iostream>
#include <filesystem>
#include <fstream>
#include <stdio.h>
#include <string>
#include <vector>

#include "state.h"

// ANSI escape codes
const std::string GREEN   = "\033[92m";   // bright green
const std::string MAGENTA = "\033[95m";   // bright
const std::string RED     = "\033[91;1m"; // bold bright
const std::string YELLOW  = "\033[33m";
const std::string RESET   = "\033[0m";

void write_file_vec_size_t
(
	const std::vector<size_t>& vec,
	const std::string& filename
)
{
	// The file first contains the size of vec and then its data

	std::ofstream file(filename, std::ios::binary);
	if (!file)
	{
		std::cerr << "Error opening file for writing." << std::endl;
		exit(EXIT_FAILURE);
	}
	std::cout << "Writing cache file \"" << filename << "\"\n";

	size_t size = vec.size();
	file.write(reinterpret_cast<const char*>(&size), sizeof(size));
	file.write(reinterpret_cast<const char*>(vec.data()), size * sizeof(size_t));

	file.close();
}

std::vector<size_t> read_file_vec_size_t(const std::string& filename)
{
	std::ifstream file(filename, std::ios::binary);
	if (!file)
	{
		std::cerr << "Error opening file for reading." << std::endl;
		exit(EXIT_FAILURE);
	}
	std::cout << "Reading cache file \"" << filename << "\"\n";

	size_t size;
	file.read(reinterpret_cast<char*>(&size), sizeof(size));
	std::cout << "size = " << size << "\n";

	std::vector<size_t> vec(size);
	vec.reserve(size + 1);  // plus 1 because we're going to get the next prime

	std::cout << "vec size = " << vec.size() << "\n";
	std::cout << "vec cap  = " << vec.capacity() << "\n";

	file.read(reinterpret_cast<char*>(vec.data()), size * sizeof(size_t));
	file.close();

	//for (auto& v: vec)
	//	std::cout << "v = " << v << "\n";

	return vec;
}

const std::string CACHE_FILENAME = "cache.bin";

size_t nth_prime_number(size_t n, std::vector<size_t>& primes)
{
	// Return the nth prime.  to be clear about off-by-one errors,
	// nth_prime_number(1) returns 2.
	//
	// Also save all primes to a binary format cache file

	//std::cout << "starting nth_prime_number()\n";
	if (n <= 0)
		return 2;

	if (primes.size() <= 0)
		primes.push_back(2);

	// Iteration below assumes we start with an odd number (+= 2)
	if (primes.size() == 1)
		primes.push_back(3);

	size_t num = primes[ primes.size() - 1 ];

	// Keep generating primes until we get to the nth one
	while (primes.size() < n)
	{
		// Check if num is divisible by any prime before it
		bool is_prime = true;
		for (size_t ip = 0; ip < primes.size(); ip++)
			if (num % primes[ip] == 0)
			{
				is_prime = false;
				break;
			}
		if (is_prime)
		{
			//std::cout << "    pushing " << num << "\n";
			primes.push_back(num);
		}

		num += 2;
	}

	//// Don't write here, because then `--test` will shrink the cache
	//write_file_vec_size_t(primes, CACHE_FILENAME);

	return primes[n-1];
}

std::string comma_delim(size_t n)
{
	// Convert a number to a string and add commas as thousands separators.
	// Could use fmtlib instead
	std::string str_bare = std::to_string(n);
	size_t nstr = str_bare.size();

	//std::cerr << "str_bare len = " << nstr << "\n";
	if (nstr <= 4)
	{
		// Stylistic preference: don't dangle a single digit for 4 digit numbers
		return str_bare;
	}

	// Should use str builder but these aren't very big
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
	std::cout
		<< MAGENTA
		<< "Running prime-of-the-day unit tests ...\n"
		<< RESET;

	size_t nfail  = 0;
	size_t ntests = 0;

	#define TEST(x) \
		ntests += 1; \
		if (!(x)) \
		{ \
			nfail++; \
			std::cerr \
				<< RED \
				<< "Error: test failure at line " << __LINE__ \
				<< " in file \"" << __FILE__ << "\"\n" \
				<< RESET; \
		}

	//********

	TEST(comma_delim(1) == "1");

	TEST(comma_delim(12) == "12");
	TEST(comma_delim(123) == "123");

	TEST(comma_delim(1234) == "1234");
	TEST(comma_delim(12345) == "12,345");
	TEST(comma_delim(123456) == "123,456");

	TEST(comma_delim(1234567) == "1,234,567");
	TEST(comma_delim(12345678) == "12,345,678");
	TEST(comma_delim(123456789) == "123,456,789");

	TEST(comma_delim(1234567891) == "1,234,567,891");
	TEST(comma_delim(12345678912) == "12,345,678,912");
	TEST(comma_delim(123456789123) == "123,456,789,123");

	//********

	std::vector<size_t> primes = {};
	TEST(nth_prime_number(0, primes) == 2); // not really defined but at least it shouldn't crash
	TEST(nth_prime_number(1, primes) == 2);
	TEST(nth_prime_number(2, primes) == 3);
	TEST(nth_prime_number(3, primes) == 5);
	TEST(nth_prime_number(4, primes) == 7);
	TEST(nth_prime_number(5, primes) == 11);
	TEST(nth_prime_number(6, primes) == 13);
	TEST(nth_prime_number(7, primes) == 17);

	// Test below cache size (no further math required)
	TEST(nth_prime_number(5, primes) == 11);
	TEST(nth_prime_number(6, primes) == 13);
	TEST(nth_prime_number(7, primes) == 17);

	// Test resetting cache
	primes = {}; TEST(nth_prime_number(1, primes) == 2);
	primes = {}; TEST(nth_prime_number(2, primes) == 3);
	primes = {}; TEST(nth_prime_number(3, primes) == 5);
	primes = {}; TEST(nth_prime_number(7, primes) == 17);

	// Whether using cache or not, you can get primes non-sequentially
	TEST(nth_prime_number(100  , primes) == 541);
	TEST(nth_prime_number(1000 , primes) == 7919);
	TEST(nth_prime_number(10000, primes) == 104729);
	TEST(nth_prime_number(10001, primes) == 104743);
	TEST(nth_prime_number(10002, primes) == 104759);

	if (nfail == 0)
		std::cout
			<< GREEN
			<< "All " << ntests << " tests passed!\n"
			<< RESET;
	else
		std::cerr
			<< RED
			<< "Error: " << nfail << " / " << ntests << " unit test(s) failed\n"
			<< RESET;

	return nfail;
}

int main(int argc, char* argv[])
{
	// The `--no-cache` arg is for testing and cache corruption recovery.
	// Hopefully I don't need the latter
	//
	// Cache is always written at end.  This just controls whether or not it is
	// read initially

	bool test = false;
	bool do_cache = true;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		//std::cerr << "arg = " << arg << "\n";
		if (arg == "--test")
			test = true;
		else if (arg == "--no-cache")
			do_cache = false;
		else
			std::cerr
				<< YELLOW
				<< "Warning: bad command line arg \"" << arg << "\"\n"
				<< RESET;
	}

	if (test)
		return unit_tests();

	// The 100,000'th prime number is 1,299,709 and can be calculated from
	// scratch without caching here in about 13 seconds.  if i continue posting
	// once a day, it will take roughly 300 years to get to that point, so there
	// aren't any concerns about run time or size_t overflow.

	//std::cout << nth_prime_number(100000) << "\n";

	auto days = PRIME_STATE_COUNT;
	std::cerr << "days = " << days << " days\n";

	std::vector<size_t> primes;
	if (do_cache && std::filesystem::exists(CACHE_FILENAME))
		primes = read_file_vec_size_t(CACHE_FILENAME);

	auto nth_prime = nth_prime_number(days, primes);
	write_file_vec_size_t(primes, CACHE_FILENAME);

	// Log nothing else after this.  the run.sh script will pickup the last line
	// of stdout for the text payload
	std::cout << comma_delim(nth_prime) << "\n";

	return 0;
}

