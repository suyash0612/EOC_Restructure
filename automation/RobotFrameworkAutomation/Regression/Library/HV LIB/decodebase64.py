import pybase64


def decode_base64object(val):
    base64Value = pybase64.b64decode(val.encode('ascii'))
    return base64Value

