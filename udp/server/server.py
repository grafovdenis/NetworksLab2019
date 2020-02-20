import binascii
import socket


def parse_message(message):
    _id = message[0:4]
    _params = message[4:8]
    _questions_count = message[8:12]
    _answers_count = message[12:16]
    _ns_count = message[16:20]
    _other = message[20:24]

    _first_domain_part_len = int(message[24:26], 16)
    _first_domain_part = ""
    for i in range(_first_domain_part_len):
        _first_domain_part += chr(
            (int(message[26 + 2 * i:26 + 2 * (i + 1)], 16)))
    _second_domain_part_begin = 26 + 2 * _first_domain_part_len + 2

    _second_domain_part_len = int(
        message[_second_domain_part_begin - 2: _second_domain_part_begin], 16)
    _second_domain_part = ""
    for i in range(_second_domain_part_len):
        _second_domain_part += chr(
            int(message[_second_domain_part_begin + 2 * i:_second_domain_part_begin + 2 * (i + 1)], 16))

    _domain = _first_domain_part + "." + _second_domain_part
    return _domain


def find_record(domain):
    f = open("records")
    for line in f:
        _domain = line.split(" ")[0]
        _ip = line.split(" ")[1]
        if (_domain == domain):
            return _ip
    return


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


def encode_url(url):
    _first = url.split(".")[0]
    _first_len = len(_first)
    _second = url.split(".")[1]
    _second_len = len(_second)
    return binascii.hexlify(_first_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_first, encoding='utf-8')) \
        + binascii.hexlify(_second_len.to_bytes(1, byteorder='big')) \
        + binascii.hexlify(bytes(_second, encoding='utf-8'))


def main():
    # message = "aaaa01000001000000000000076578616d706c6503636f6d0000010001"
    UDP_IP = "127.0.0.1"
    UDP_PORT = 5005

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    sock.bind((UDP_IP, UDP_PORT))

    while(True):
        data, addr = sock.recvfrom(2048)  # buffer size is 1024 bytes
        message = binascii.hexlify(data).decode("utf-8")
        print("recceived message:", message)
        parse_message(message)
        _domain = parse_message(message)
        _ip = find_record(_domain)

        # header
        _id = "AA AA "
        _params = "81 80 "
        _questions_count = "00 01 "
        _answers_count = "00 01 "
        _ns_count = "00 00 "
        _other = "00 00 "
        _header = _id + _params + _questions_count + _answers_count + _ns_count + _other
        # question
        _host = str(encode_url(_domain))[1:].replace("'", "")
        _q_type = "00 01 "
        _q_class = "00 01 "
        _question = _host + _q_type + _q_class
        # answer
        _name = "C0 0C "
        _type = "00 01"
        _class = "00 01"
        _something = "00 00"
        _ttl = "18 4C"
        _rd_len = "00 04"
        __ip = _ip.split(".")
        ip = ""
        for i in __ip:
            _hex = hex(int(i, 10))[2:]
            ip += "0" + _hex if (len(_hex) == 1) else _hex
        _answer = _name + _type + _class + _something + _ttl + _rd_len + ip
        _result = (_header + _question + _answer).replace(
            " ", "").lower()
        sock.sendto(binascii.unhexlify(_result), (UDP_IP, UDP_PORT + 1))
        print(_result, "sent")


if __name__ == "__main__":
    main()
