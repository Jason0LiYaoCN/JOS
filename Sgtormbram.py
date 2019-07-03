Rate_changcheng = float(input("please input changcheng rate: "))
Rate_DBS = float(input("please input dbs rate: "))
sgmoney = int(input("input sgd you need to transfer: "))

actualrate = (Rate_changcheng * sgmoney) / (sgmoney + 18)
moneysave = 0
if (actualrate > Rate_DBS):
    print("you need to go to changcheng! changcheng rate is : ", actualrate)
    moneysave = (Rate_changcheng - Rate_DBS) * sgmoney - Rate_DBS*18
    print("moneysave is: " , moneysave, "RMB")
else:
    print("you need to go to dbs! dbs rate is :", Rate_DBS)
    moneysave = (Rate_changcheng - Rate_DBS) * sgmoney - Rate_DBS*18
    moneysave = -1 * moneysave
    print("moneysave is: " , moneysave, "RMB")
