# OSI Model

![osi-model](https://github.com/user-attachments/assets/1989e543-6187-44e7-9563-c90ab1246816)

The OSI Model or Open Systems Interconnection Model is a conceptual framework that standardizes how data moves across a network. It separates into 7 distinct layers, based on the specific jobs they perform.

## 7. Application 🌐
The Application Layer serves as the direct interface where software applications request network resources. It does not run the application, but it powers the network capabilities within it. 

- PDU: Data
- Protocols & Services: HTTP/HTTPS (Web Browsing), SSH (Secure Shell), FTP/SFTP (File Transfer), SMTP (Email), DNS (Domain Names Resolution), DHCP (IP assignment).

**Scenario:** Typing "Hello World!" and attach a photo in your chat app then hit **send**. The app requests network access to push your specific data payload to the chat server.

## 6. Presentation 🎨
The Presentation Layer functions as the network's data translator and security gatekeeper, ensuring that the application layer receives data in a readable, standardized syntax. It manages data translation, handles background compression to shrink file sizes before transmission, and run encryption protocols.

- PDU: Data
- Standards & Formats: SSL/TLS (Encryption), ASCII/UTF-8 (Text formatting), JPEG/PNG (Images), MP4/MKV (Video), GIF, MDI.

**Scenario:** The app scrambles your message using TLS encryption so no one can intercept it, and compresses the `.jpg` photo to save data. The raw texts and image are now formatted into a secure, compressed, and standardized syntax.

## 5. Session 🪵
The Session Layer acts as the session coordinator, building, monitoring, and dismantling the ongoing virtual dialogs between the local machine and remote nodes. It establishes logic for data flows and drops logical 'checkpoints' into the transmissions stream. If the network drops, it uses them to know exactly where to resume rather than restarting from zero.

- PDU: Data
- Protocols & APIs: NetBIOS, RPC (Remote Procedure Call), SOCKS, PPTP, SQL session management.

**Scenario:** The background service checks to ensure your active "login session" with the chat server is still alive and opens the channel for transmission. A synced dialogue is established. If you briefly lose the cellular service, the session holds in place so the message sends when you reconnect.

## 4. Transport 📦
The Transport Layer handles host-to-host data delivery logic, multiplexing applications onto a single network interface using assigned logical numbers. It segments large data payloads into manageable units (Segments for TCP, Datagrams for UDP) and attaches source/destination **Port Numbers**. It actively manages flow control to prevent faster senders from flooding slower receivers and handles packet retransmission via sequence tracking.

- PDU: Segments (TCP) / Datagrams (UDP)
- Protocols: TCP (Transmission Control Protocol), UDP (User Datagram Protocol).
- Identifiers & Hardware: Source Ports and Destination Ports (Port 443 for HTTPS, Port 22 for SSH).

**Scenario:** **TCP** takes your encrypted message/photo and chops it into smaller, numbered pieces. It slaps on a Destination Port so the receiving server knows this data is for the web service, not an email service. Your data is now broken into multiple **Segments**, tracked by sequence numbers so they can be reassembled in perfect order later.

## 3. Network 🗺️
The Network Layer manages multi-network routing and logical destination addressing across the global internet infrastructure. It encapsulates Transport Layer segments into **Packets**, write source and destination IP addresses onto the headers, and runs routing protocols to calculate the most efficient path across entirely separate networks.

- PDU: Packets
- Protocols: IPv4, IPv6, ICMP (ping), IPSec, OSPF, BGP.
- Hardware: Routers, Layer 3 Switches.

**Scenario:** The Internet Protocol (IP) takes those segments and slaps on a "shipping label". It adds your phone's IP address and the chat server's IP address as Source and Destination. Your **Segments** are now wrapped inside **Packets**. The network now knows where on the globe this data needs to go.

## 2. Data Link 🚚
The Data Link Layer directs the physical delivery of data frames between two directly adjacent hardware devices operating on the exact same local network (LAN). It packs network packets into hardware-ready **Frames**, mark them with permanent physical **MAC Addresses**. It uses a tail-end Frame Check Sequence (FCS) to detect localized errors and coordinates media access control so multiple devices do not talk over each other.

This Layer can be split into two distinct sublayers:

1. LLC (Logical Link Control): The upper sublayer. It talks to the Network Layer handles error checking and synchronizes frames.
2. MAC (Media Access Control): The lower sublayer. It talks to the Physical Layer manages physical addressing, and control hardware access to the media.

- PDU: Frames
- Protocols & Standards: Ethernet (802.3), Wi-Fi (802.11), ARP (Address Resolution Protocol), PPP.
- Identifiers & Hardware: MAC Address, Network  Switches, Network Interface Cards (NICs).

**Scenario:** Your phone wraps the packet for local delivery. It adds your phone's physical MAC Address and the local Wi-Fi router's MAC Address. It also calculates a mathematical checksum to catch any error during transit. Your packets are now wrapped inside **Frames**. The hardware knows exactly which local device needs to receive the data next.

## 1. Physical ⚡
The Physical Layer governs the raw physical hardware, mechanical connectors, and signal pathways that transport raw data streams. It translates higher-level logical data structures into unformatted, binary bitstreams (`1s and 0s`). Then convert them into measurable physical phenomena such as electrical voltages, light pulses, or radio frequencies without assigning any logic or meaning to the data.

- PDU: Bits
- Cables & Mediums: Cat6 Ethernet cables, Fiber-optic strands, Coaxial cables. Radio waves (2.4GHz/ 5 GHz Wi-Fi).
- Hardware Components: RJ45 connectors, Hubs, Repeaters, SFP modules.

**Scenario:** Your phone's internal antenna takes the framed data (binary `1s and 0s`) and blasts it through the air as 5GHz radio waves toward your Wi-Fi router. The logical data is now a **Physical Signal** officially leaving your device.

### Interactive Model: https://osi-model-web.vercel.app/