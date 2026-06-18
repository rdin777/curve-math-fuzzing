# pragma version 0.3.10
# pragma evm-version shanghai
"""
@title CurveStableSwapNGMath
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2020-2023 - all rights reserved
@notice Math for StableSwapMetaNG implementation (Optimized)
"""

MAX_COINS: constant(uint256) = 8
MAX_COINS_128: constant(int128) = 8
A_PRECISION: constant(uint256) = 100

@external
@pure
def get_y(
    i: int128,
    j: int128,
    x: uint256,
    xp: DynArray[uint256, MAX_COINS],
    _amp: uint256,
    _D: uint256,
    _n_coins: uint256
) -> uint256:
    n_coins_128: int128 = convert(_n_coins, int128)
    assert i != j
    assert j >= 0
    assert j < n_coins_128
    assert i >= 0
    assert i < n_coins_128

    amp: uint256 = _amp
    D: uint256 = _D
    S_: uint256 = 0
    _x: uint256 = 0
    c: uint256 = D
    Ann: uint256 = amp * _n_coins

    for _i in range(MAX_COINS_128):
        if _i == n_coins_128:
            break
        if _i == i:
            _x = x
        elif _i != j:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * _n_coins)

    c = c * D * A_PRECISION / (Ann * _n_coins)
    b: uint256 = S_ + D * A_PRECISION / Ann
    y: uint256 = D

    for _i in range(255):
        y_prev: uint256 = y
        y = (y*y + c) / (2 * y + b - D)
        if y > y_prev:
            if y - y_prev <= 1: return y
        else:
            if y_prev - y <= 1: return y
    raise

@external
@pure
def get_D(
    _xp: DynArray[uint256, MAX_COINS],
    _amp: uint256,
    _n_coins: uint256
) -> uint256:
    S: uint256 = 0
    for x in _xp:
        S += x
    if S == 0:
        return 0

    D: uint256 = S
    Ann: uint256 = _amp * _n_coins

    for i in range(255):
        D_P: uint256 = D
        for x in _xp:
            D_P = D_P * D / x
        D_P /= pow_mod256(_n_coins, _n_coins)
        Dprev: uint256 = D

        # ОПТИМИЗИРОВАННАЯ ФОРМУЛА С СОХРАНЕНИЕМ ТОЧНОСТИ
        # D = (Ann * S / A_PRECISION + D_P * _n_coins) * D / ((Ann - A_PRECISION) * D / A_PRECISION + (_n_coins + 1) * D_P)
        
        term1: uint256 = unsafe_div(Ann * S, A_PRECISION)
        term2: uint256 = D_P * _n_coins
        numerator: uint256 = (term1 + term2) * D
        
        term3: uint256 = unsafe_div((Ann - A_PRECISION) * D, A_PRECISION)
        term4: uint256 = unsafe_add(_n_coins, 1) * D_P
        denominator: uint256 = term3 + term4
        
        D = numerator / denominator
        
        if D > Dprev:
            if D - Dprev <= 1: return D
        else:
            if Dprev - D <= 1: return D
    raise

# Остальные функции (get_y_D, exp) остаются без изменений
@external
@pure
def get_y_D(
    A: uint256,
    i: int128,
    xp: DynArray[uint256, MAX_COINS],
    D: uint256,
    _n_coins: uint256
) -> uint256:
    n_coins_128: int128 = convert(_n_coins, int128)
    assert i >= 0
    assert i < n_coins_128
    S_: uint256 = 0
    _x: uint256 = 0
    c: uint256 = D
    Ann: uint256 = A * _n_coins
    for _i in range(MAX_COINS_128):
        if _i == n_coins_128: break
        if _i != i: _x = xp[_i]
        else: continue
        S_ += _x
        c = c * D / (_x * _n_coins)
    c = c * D * A_PRECISION / (Ann * _n_coins)
    b: uint256 = S_ + D * A_PRECISION / Ann
    y: uint256 = D
    for _i in range(255):
        y_prev: uint256 = y
        y = (y*y + c) / (2 * y + b - D)
        if y > y_prev:
            if y - y_prev <= 1: return y
        else:
            if y_prev - y <= 1: return y
    raise

@external
@pure
def exp(x: int256) -> uint256:
    value: int256 = x
    if (x <= -41446531673892822313): return empty(uint256)
    assert x < 135305999368893231589, "wad_exp overflow"
    value = unsafe_div(x << 78, 5 ** 18)
    k: int256 = unsafe_add(unsafe_div(value << 96, 54916777467707473351141471128), 2 ** 95) >> 96
    value = unsafe_sub(value, unsafe_mul(k, 54916777467707473351141471128))
    y: int256 = unsafe_add(unsafe_mul(unsafe_add(value, 1346386616545796478920950773328), value) >> 96, 57155421227552351082224309758442)
    p: int256 = unsafe_add(unsafe_mul(unsafe_add(unsafe_mul(unsafe_sub(unsafe_add(y, value), 94201549194550492254356042504812), y) >> 96, 28719021644029726153956944680412240), value), 4385272521454847904659076985693276 << 96)
    q: int256 = unsafe_add(unsafe_mul(unsafe_sub(value, 2855989394907223263936484059900), value) >> 96, 50020603652535783019961831881945)
    q = unsafe_sub(unsafe_mul(q, value) >> 96, 533845033583426703283633433725380)
    q = unsafe_add(unsafe_mul(q, value) >> 96, 3604857256930695427073651918091429)
    q = unsafe_sub(unsafe_mul(q, value) >> 96, 14423608567350463180887372962807573)
    q = unsafe_add(unsafe_mul(q, value) >> 96, 26449188498355588339934803723976023)
    r: int256 = unsafe_div(p, q)
    return unsafe_mul(convert(convert(r, bytes32), uint256), 3822833074963236453042738258902158003155416615667) >> convert(unsafe_sub(195, k), uint256)
