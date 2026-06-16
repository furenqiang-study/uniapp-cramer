import py_compile
try:
    py_compile.compile('init_entertainment.py', doraise=True)
    print('SYNTAX OK')
except Exception as e:
    print(f'SYNTAX ERROR: {e}')