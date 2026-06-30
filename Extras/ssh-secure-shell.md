# SSH (Secure Shell)

SSH is a cryptographic network protocol used to securely access, control, and transfer files between computers over an unsecured network, like the internet. It operates on TCP port 22.

## TCP vs UDP

TCP and UDP are both transport layer of the internet's structural models. They belong to Layer 4 of the OSI (Open Systems Interconnection) Model and the Transport Layer of the TCP/IP Model.

### TCP (Transmission Control Protocol)

TCP or Transmission Control Protocol is the foundational transport-layer that underpins the majority of internet communication. 

Commonly used for internet services where data loss is unacceptable such as, web browsing (HTTP/HTTPS), email (SMTP, IMAP), file transfer (FTP, SFTP), and remote management (SSH).

- **Connection-Oriented**: It requires a logical connection to be established between the _sender_ and _receiver_ before any data is exchanged. 

- **Three-Way Handshake**: The foundational connection establishment process includes:
    
    1. `SYN (Synchronize)`: Client sends `SYN` packet to initiate the connection.

    2. `SYN-ACK (Synchronize-Acknowledge)`: Server receives the `SYN` and responds with a `SYN-ACK` packet.

    3. `ACK (Acknowledge)`: Client responds with an `ACK` packet to complete the handshake. 

- **Reliable Delivery**: It uses sequence numbers and acknowledegements to **ensure no data is lost** or duplicated, and that bytes arrive in the exact order they were sent.

- **Flow Control**: It utilizes a _sliding window_ mechanism to prevent a fast sender from overwhelming a slower receiver.

- **Congestion Control**: It monitors traffic and dynamically adjusts the data transmission speed to prevent network overload.

- **Error Checking**: Includes checksums to detect corrupted segments. The damaged packets are automatically retransmitted.



### UDP (User Datagram Protocol)

UDP or User Datagram Protocol is a lightweight, connectionless transport-layer protocol designed for speed and efficiency. It sends data packets (datagrams) directly to the destination without establishing a prior connection or verifying receipt.

Commonly used for real-time services where speed matters more than occational lost packets such as, live streaming (YouTube, Twitch), online gaming, voice over IP (VoIP, Zoom, Skype, Discord), DNS.


- **Connectionless**: It sends data immedietely without a handshake, reducing latency.

- **Best-Effort Delivery**: It does not guarantee packets will arrive, stay in order, or avoid duplication.

- **No Flow or Congestion Control**: Transmits data at a constant rate, regardless of network congestion.

- **Low Overhead**: Uses an 8-byte header, compared to TCP's minimum 20-byte header.

- **Supports Broadcasting**: Can send a single packet to multiple destinations simultaneously.

<img width="750" height="450" alt="image" src="https://github.com/user-attachments/assets/6700232a-12d0-4e84-b146-c2e3a3100af7" />


## SSH Between 2 VMs

1. Install SSH server

    ```
    sudo apt update
    sudo apt install openssh-server -y
    ```

    Start and enable it:
    ```
    sudo systemctl start ssh
    sudo systemctl enable ssh
    ```
    Verify:
    ```
    sudo systemctl status ssh
    ```
    Output:
    ```
    Active: active (running)
    ```

2. Configure permanent IPs on both VM via Netplan

    **VM1**:     
    ```
    sudo nano /etc/netplan/50-cloud-init.yaml
    ```
    Configure `50-cloud-init.yaml`:
    ```
    network:
      version: 2
      ethernets:
        enp0s8:
          dhcp4: true
        enp0s9:
          addresses: [192.168.100.1/24]
          dhcp4: false
    ```

    **VM2**:
    ```
    sudo nano /etc/netplan/50-cloud-init.yaml
    ```
    Configure `50-cloud-init.yaml`:
    ```
    network:
      version: 2
      ethernets:
        enp0s8:
          dhcp4: true
        enp0s9:
          addresses: [192.168.100.2/24]
          dhcp4: false
    ```

    **Apply on both**:
    ```
    sudo netplan apply
    ```

3. SSH Key Setup

    **VM1**:
    
    Generate the key.
    ```
    ssh-keygen -t ed25519
    ```
    Copy key to VM2.
    ```
    ssh-copy-id vm2@192.168.100.2
    ```

    **VM2**:

    Generate the key.
    ```
    ssh-keygen -t ed25519
    ```
    Copy key to VM1.
    ```
    ssh-copy-id vm1@192.168.100.1
    ```

4. Test

    From VM1:
    ```
    ssh vm2@192.168.100.2
    exit
    ```

    From VM2:
    ```
    ssh vm1@192.168.100.1
    exit
    ```

    This should allow you to remotely connect to and control another machine.


## From Local Machine to VM

1. Configure the network settings.

    In Network Settings inside VirtualBox:
        
    Select `Port Forwarding`:

    |Name|Protocol|Host IP|Host Port|Guest IP|Guest Port|
    |:---:|:---:|:---:|:---:|:---:|:---:|
    |SSH|TCP|(blank)|2222|(blank)|22|

2. From local machine terminal.

    ```
    ssh vm1@127.0.0.1 -p 2222
    ```
    This connects through the local machine and forwarded to VM1's port 22.

You should now be able to connect to VM1.
