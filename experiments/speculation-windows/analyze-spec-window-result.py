import argparse

N_LOADS = 11

ITERATIONS = 10000

def main(file):

    load_results = {}
    load_results_min = {}
    load_results_max = {}

    for i in range(1, N_LOADS + 1):
        load_results[i] = 0
        load_results_min[i] = 9999999999
        load_results_max[i] = 0

    number_of_tests = 0
    max_hits = 0

    with open(file) as f:

        for line in f:
            if "TEST" not in line:
                continue
            if "MODE" in line:
                continue
            if "PLEASE" in line:
                continue
            if "SIBLINGS" in line:
                continue

            values = line.split()

            # assert(len(values) == N_LOADS + 1)

            for i in range(1, N_LOADS + 1):
                hits = int(values[i])
                load_results[i] += hits

                if hits > max_hits:
                    max_hits = hits

                if hits > load_results_max[i]:
                    load_results_max[i] = hits

                if hits < load_results_min[i]:
                    load_results_min[i] = hits


            number_of_tests += 1


    if max_hits > ITERATIONS:
        print(f"Invalid results! max_hits ({max_hits}) > ITERATIONS ({ITERATIONS})")
        exit(1)

    print(f"Number of test results: {number_of_tests} MAX Hits: {max_hits}")

    print("     ", end='')
    for i in range(1, N_LOADS + 1):
        print(f"{i} LOAD | ", end='')

    print("\nAVG  ", end='')
    for i in range(1, N_LOADS + 1):
        n = (load_results[i] / (ITERATIONS * number_of_tests)) * 100
        print(f"{n:>6.2f}%  ", end='')

    print("\nMAX  ", end='')
    for i in range(1, N_LOADS + 1):
        n = (load_results_max[i] / (ITERATIONS)) * 100
        print(f"{n:>6.2f}%  ", end='')


    print("\nMIN  ", end='')
    for i in range(1, N_LOADS + 1):
        n = (load_results_min[i] / (ITERATIONS)) * 100
        print(f"{n:>6.2f}%  ", end='')

    print("")




if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser(description='Analyze IBT window output')
    arg_parser.add_argument('file')

    args = arg_parser.parse_args()

    main(args.file)
