int div(int a, int b)
{
    int q, x;

    q = 0;
    x = b;

    while (x <= (a >> 1))
        x <<= 1;
    while (x >= b) {
        if (a >= x) {
            q |= 1;
            a -= x;
        }
        x >>= 1;
        q <<= 1;
    }
    q >>= 1;

    return q;
}
