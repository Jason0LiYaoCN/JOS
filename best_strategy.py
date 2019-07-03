rate_array = []
Rate_changcheng0 = float(input("[0,1000] rate is : "))
rate_array.append(Rate_changcheng0)
Rate_changcheng1 = float(input("(1000,2000] rate is : "))
rate_array.append(Rate_changcheng1)
Rate_changcheng2 = float(input("(2000,5000] rate is : "))
rate_array.append(Rate_changcheng2)
Rate_changcheng3 = float(input("(5000,20000] rate is : "))
rate_array.append(Rate_changcheng3)
Rate_changcheng4 = float(input("(20000,50000] rate is : "))
rate_array.append(Rate_changcheng4)
money_array = [1000,2000,5000,20000,50000]

actualrate_array = []

for i in range(len(rate_array)):
    actualrate = (money_array[i] * rate_array[i])/(money_array[i]+18)
    actualrate_array.append(actualrate)

for i in actualrate_array:
    print(i)

print("best strategy is to transfer",money_array[actualrate_array.index(max(actualrate_array))], "at rate: ", max(actualrate_array))

