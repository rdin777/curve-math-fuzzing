import random
from ape import accounts, project

def test_fuzz_get_y_hardcore():
    owner = accounts.test_accounts[0]
    tester = project.TestCurveMath.deploy(sender=owner)
    
    # ДОБАВЬ СЮДА: расширяем наш список экстремальных значений
    max_uint256 = 2**256 - 1
    edge_cases = [0, 1, 10**18, 10**24, max_uint256] 
    
    for i in range(2000):
        # Если случайное число меньше 0.2, выбираем из наших "опасных" значений
        if random.random() < 0.2:
            x = random.choice(edge_cases)
        else:
            x = random.randint(10**17, 10**21)
            
        amp = 1
        D = 10**15
        
        # Вызов
        result = tester.test_get_dy(0, 1, x)
        
        print(f"Fuzz {i}: x={x} -> result={result}")
