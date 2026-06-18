# @version 0.3.10

@external
@view
def test_get_dy(i: int128, j: int128, dx: uint256) -> uint256:
    # Удаляем строки 'i: int128 = 0' и 'j: int128 = 1', так как они уже есть в аргументах
    
    n_coins: uint256 = 2
    amp: uint256 = 1
    D: uint256 = 10**15
    xp: uint256[2] = [10**18, 10**18]
    
    # Теперь используем i и j, которые пришли аргументами
    # Внутренняя логика расчета (минимальный PoC)
    S_: uint256 = xp[0] + xp[1]
    c: uint256 = D * D / (xp[0] * n_coins)
    
    # Вычисляем результат
    y: uint256 = (c * D) / (amp * n_coins)
    
    return y
