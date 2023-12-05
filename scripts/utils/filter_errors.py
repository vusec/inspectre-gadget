f = open("fail.txt")

errors = []
str = ""

for l in f:
    if "ERROR" in l:
        errors.append(str)
        str = l
    else:
        str += l

for e in errors:
    if not "You can" in e:
        print(e)


