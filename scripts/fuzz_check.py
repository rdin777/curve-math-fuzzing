import random
from ape import project, accounts

def get_D_python(xp, amp, n_coins):
    """Reference Mathematics in Python"""
    S = sum(xp)
    if S == 0: return 0
    D = S
    Ann = amp * n_coins
    for _ in range(255):
        D_P = D
        for x in xp:
            D_P = D_P * D // (x * n_coins)
        Dprev = D
        # Formula separating the numerator and denominator for accuracy
        numerator = (Ann * S // 100 + D_P * n_coins) * D
        denominator = (Ann - 100) * D // 100 + (n_coins + 1) * D_P
        D = numerator // denominator
        if abs(D - Dprev) <= 1: return D
    return D

def main():
    sender = accounts.test_accounts[0]
    contract = project.CurveStableSwapNGMath.deploy(sender=sender)
    
    print("--- Launching the Curve math stress test ---")
    
    for i in range(10): # We run 10 random tests.
        n_coins = 4
        amp = random.randint(1, 10000)
        # Generating random balances (XP)
        xp = [random.randint(10**17, 10**21) for _ in range(n_coins)]
        
        vyper_D = contract.get_D(xp, amp, n_coins)
        py_D = get_D_python(xp, amp, n_coins)
        
        if abs(vyper_D - py_D) <= 1:
            print(f"Тест {i}: OK (A={amp}, D={vyper_D})")
        else:
            print(f"!!! Bug on the test server {i} !!!")
            print(f"Parameters: A={amp}, xp={xp}")
            print(f"Vyper: {vyper_D}, Python: {py_D}")
            break
    else:
        print("--- All tests passed successfully! ---")

if __name__ == "__main__":
    main()
