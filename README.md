# MATRISC: Iterative Methods for Linear Systems

## Overview

This project implements iterative methods for solving linear systems in RISC-V assembly language. The methods include Jacobi, Gauss-Seidel, and Successive Over-Relaxation (SOR). These algorithms are fundamental in computational science for solving large sparse systems efficiently.

The project is part of the course "Principles of Computer Systems and Scientific Computing 1" at the university.

## Implemented Methods

- **Jacobi Method**: A basic iterative technique that uses the previous iteration's values to compute the next.
- **Gauss-Seidel Method**: An improvement over Jacobi that uses the most recent values as soon as they are computed.
- **SOR Method**: A generalization of Gauss-Seidel with a relaxation parameter ω for faster convergence.

## Files

- `Jacobi.asm`: RISC-V assembly implementation of the Jacobi method.
- `GaussSeidel.asm`: RISC-V assembly implementation of the Gauss-Seidel method.
- `SOR.asm`: RISC-V assembly implementation of the SOR method.

## Authors

- Pouria Moradpour
- Yahya Izadi

## Course

Principles of Computer Systems and Scientific Computing 1

---

# MATRISC: روش‌های تکراری برای حل سیستم‌های خطی

## نمای کلی

این پروژه روش‌های تکراری برای حل سیستم‌های خطی را در زبان اسمبلی RISC-V پیاده‌سازی می‌کند. این روش‌ها شامل ژاکوبی، گاوس-سایدل و آرام‌سازی متوالی (SOR) هستند. این الگوریتم‌ها در محاسبات علمی برای حل کارآمد سیستم‌های بزرگ و پراکنده اساسی هستند.

این پروژه بخشی از درس "اصول سیستم‌های کامپیوتری و محاسبات علمی ۱" در دانشگاه است.

## روش‌های پیاده‌سازی شده

- **روش ژاکوبی**: یک تکنیک تکراری پایه که از مقادیر تکرار قبلی برای محاسبه تکرار بعدی استفاده می‌کند.
- **روش گاوس-سایدل**: بهبود بر روی ژاکوبی که از مقادیر اخیر به محض محاسبه استفاده می‌کند.
- **روش SOR**: تعمیم گاوس-سایدل با پارامتر آرام‌سازی ω برای همگرایی سریع‌تر.

## فایل‌ها

- `Jacobi.asm`: پیاده‌سازی اسمبلی RISC-V روش ژاکوبی.
- `GaussSeidel.asm`: پیاده‌سازی اسمبلی RISC-V روش گاوس-سایدل.
- `SOR.asm`: پیاده‌سازی اسمبلی RISC-V روش SOR.

## نویسندگان

- پوریا مرادپور
- یحیىٰ ایزدی

## درس

اصول سیستم‌های کامپیوتری و محاسبات علمی ۱
