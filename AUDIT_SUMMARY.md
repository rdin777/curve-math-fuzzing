# CurveStableSwapNG Math Audit & Fuzzing

## Overview
This repository contains a fuzzing suite for `CurveStableSwapNGMath`. The goal was to verify the mathematical integrity of the AMM formulas under extreme conditions.

## Methodology
- **Framework**: Ape Framework (Vyper 0.3.10).
- **Technique**: Stateful Fuzzing with boundary value analysis.
- **PoC**: Created a self-contained `TestCurveMath.vy` to isolate the `get_y` function.

## Key Findings
- **Integer Overflow**: The implementation proved resistant to overflow at `MAX_UINT256`.
- **Zero-Input Stability**: Verified that the math does not collapse to 0 for small values (e.g., `dx=1`), preventing liquidity drain scenarios.

## How to run
```bash
ape compile
ape test tests/stateful_swap_fuzz.py
