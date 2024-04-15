def fib(n):
    if n == 0:
        return 1
    elif n == 1:
        return 1
    else:
        return fib(n - 1) + fib(n - 2)


def fac(n):
    if n == 0:
        return 1
    else:
        return n * fac(n - 1)
