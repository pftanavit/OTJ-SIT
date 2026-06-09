# IP (Internet Protocol)

- IP address is the unique numerical label assigned to every single device connected to a network.
- It serves as an address for sending and receiving data on the Internet.

# IPv4

- It is the original addressing system of the internet. It uses a 32-bit format, which is written as four blocks of numbers separated by periods.
- For example, `192.168.1.0`
- Each block ranges from 0 to 255.

- Since it consist of 4 blocks, it is limited to around 2^32 or 4.3 billion addresses.
- IPv6 is now the most recent version of IP, using 128-bit addresses.

# Subnet

- Since the addresses are limited, subnetting divides the network and slices it into smaller chunks.
- This helps organize the networks and devices to avoid conflicting or overloading.

## Subnet Masks

- A subnet mask is a 32-bit number used in IPv4 networking that helps divide an IP address into two components: the network portion and the host portion.
- For example: `255.255.255.0` or `/24`.
- `255` means that that portion is locked for Network ID.
- `0` means that it is for Host ID.

![image1](https://github.com/user-attachments/assets/bd7e9da0-f739-498c-8128-2eec1fa6e21d)

## Network ID and Host ID

- The Network ID and Host ID are exactly what the subnet mask splits apart.
- A `255.255.255.0` (`/24`) mask only leaves the very last block for host IDs. That limits the network to about 254 devices, which is too small for 500 computers.
- A `255.255.0.0` (`/16`) mask leaves the last two blocks open for host IDs. This allows for up to 65,534 unique host IDs, which easily fits all 500 computers with plenty of room to grow.
