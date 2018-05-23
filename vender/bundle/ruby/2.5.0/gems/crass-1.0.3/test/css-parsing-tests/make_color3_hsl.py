import colorsys  # It turns out Python already does HSL -> RGB!
trim = lambda s: s if not s.endswith('.0') else s[:-2]
print('[')
print(',\n'.join(
    '"hsl%s(%s, %s%%, %s%%%s)", [%s, %s, %s, %s]' % (
        ('a' if a is not None else '', h, trim(str(s/10.)), trim(str(l/10.)),
         ', %s' % a if a is not None else '')
        + tuple(trim(str(round(v, 10)))
                for v in colorsys.hls_to_rgb(h/360., l/1000., s/1000.))
        + (a if a is not None else 1,)
    )
    for a in [None, 1, .2, 0]
    for l in range(0, 1001, 125)
    for s in range(0, 1001, 125)
    for h in range(0, 360, 30)
))
print(']')
