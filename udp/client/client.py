import binascii
import socket


def send_udp_message(message, address, port):
    """send_udp_message sends a message to UDP server

    message should be a hexadecimal encoded string
    """
    message = message.replace(" ", "").replace("\n", "")
    server_address = (address, port)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.sendto(binascii.unhexlify(message), server_address)
        data, _ = sock.recvfrom(4096)
    finally:
        sock.close()
    return binascii.hexlify(data).decode("utf-8")


def format_hex(hex):
    """format_hex returns a pretty version of a hex string"""
    octets = [hex[i:i+2] for i in range(0, len(hex), 2)]
    pairs = [" ".join(octets[i:i+2]) for i in range(0, len(octets), 2)]
    return "\n".join(pairs)


_id = "AA AA "
_params = "01 00 "
_questions_num = "00 01 "
_answers_num = "00 00 "
_ns_num = "00 00 "
_other = "00 00 "


def encode_url(url):
    _first = url.split(".")[0]
    _first_len = len(_first)
    _second = url.split(".")[1]
    _second_len = len(_second)
    return binascii.hexlify(_first_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_first, encoding='utf-8')) \
        + binascii.hexlify(_second_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_second, encoding='utf-8'))


message = _id + _params + _questions_num + _answers_num + _ns_num + _other \
    + encode_url("example.com").decode("utf-8") + " 00 00 01 00 01"

response = send_udp_message(message, "1.1.1.1", 53)
print(format_hex(response))
print(response)