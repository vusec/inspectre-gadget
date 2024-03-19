import argparse

def get_call_targets(target_addresses, all_text_symbols):


    filter_addresses = []

    with open(target_addresses) as f:

        for line in f:
            address = line.strip().split(',')[0]
            filter_addresses.append(address)

    filter_addresses = set(filter_addresses)

    with open(all_text_symbols) as f:
        for line in f:
            address = line.strip().split(',')[0]
            if address in filter_addresses:
                print(line.strip())


def get_jump_targets(target_addresses, all_text_symbols):

    filter_addresses = []

    with open(all_text_symbols) as f:

        for line in f:
            address = line.strip().split(',')[0]
            filter_addresses.append(address)

    filter_addresses = set(filter_addresses)

    with open(target_addresses) as f:
        for line in f:
            address = line.strip().split(',')[0]
            if address not in filter_addresses:
                print(line.strip())



def main(mode, target_addresses, all_text_symbols):

    if mode == "call-targets":
        get_call_targets(target_addresses, all_text_symbols)
    else:
        get_jump_targets(target_addresses, all_text_symbols)



if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser(description='Filter addresses file')
    arg_parser.add_argument('mode', choices=['call-targets', 'jump-targets'])
    arg_parser.add_argument('target_addresses')
    arg_parser.add_argument('all_text_symbols')
    arg_parser.add_argument('-of', '--output-folder', type=str, required=False)

    args = arg_parser.parse_args()

    main(args.mode, args.target_addresses, args.all_text_symbols)
