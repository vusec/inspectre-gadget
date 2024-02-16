f = open("fail.txt")

errors = {}

str = ""
count = 0

for l in f:
    if "ERROR" in l:
        if str in errors.keys():
            errors[str] += 1
        else:
            errors[str] = 1

        str = ""
        count = 0

    else:
        if count == 1:
            str += l.replace("\n","")
        count += 1

# print(errors)

for e in errors:
    if not "You can" in e and not "No bytes" in e:
        print(errors[e], '\t', e)
