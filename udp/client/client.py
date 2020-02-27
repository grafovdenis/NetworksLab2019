import binascii
import socket
import sys


def send_udp_message(message, address, port):
    """send_udp_message sends a message to UDP server

    message should be a hexadecimal encoded string
    """
    message = message.replace(" ", "").replace("\n", "")
    server_address = (address, port)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock_res = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock_res.bind((address, port + 1))
    try:
        sock.sendto(binascii.unhexlify(message), server_address)
        data, _ = sock_res.recvfrom(4096)
    finally:
        sock.close()
    return binascii.hexlify(data).decode("utf-8")


def format_hex(hex):
    """format_hex returns a pretty version of a hex string"""
    octets = [hex[i:i+2] for i in range(0, len(hex), 2)]
    pairs = [" ".join(octets[i:i+2]) for i in range(0, len(octets), 2)]
    return "\n".join(pairs)


def encode_url(url):
    _first = url.split(".")[0]
    _first_len = len(_first)
    _second = url.split(".")[1]
    _second_len = len(_second)
    return binascii.hexlify(_first_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_first, encoding='utf-8')) \
        + binascii.hexlify(_second_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_second, encoding='utf-8'))


def print_ip(res):
    ip = res[-8:]
    print(int(ip[0:2], 16), int(ip[2: 4], 16), int(
        ip[4: 6], 16), int(ip[6: 8], 16), sep='.')
    return


def print_answers_count(res):
    count = int(res[:16][-4:], 16)
    print("Answers recieved:", count)
    return


def main():
    _id = "AA AA "
    _params = "01 00 "
    _questions_count = "00 01 "
    _answers_count = "00 00 "
    _ns_count = "00 00 "
    _other = "00 00 "
    _domain = sys.argv[1] if len(sys.argv) > 1 \
        and sys.argv[1] != None else "example.com"
    print("Looking for ip of", _domain)

    message = _id + _params + _questions_count + _answers_count + _ns_count + _other \
        + encode_url(_domain).decode("utf-8") + " 00 00 01 00 01"

    # response = send_udp_message(message, "1.1.1.1", 53)
    response = send_udp_message(message, "127.0.0.1", 5005)

    # print(format_hex(response))
    # print(response)
    print_answers_count(response)
    print_ip(response)


if __name__ == "__main__":
    main()
