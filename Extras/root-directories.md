## Core macOS Directories

- `Applications`: Contains all the graphical applications installed on the Mac (e.g., Safari, Mail, or third-party apps) that are accessible to all users on the computer.
- `Library`: Holds system-wide preferences, application support files, fonts, and plugins. These resources are shared by all users but are not part of the core operating system.
- `System`: This is the heart of macOS. It contains the core operating system files, frameworks, and drivers. On modern macOS, this is a completely read-only volume protected by cryptographic security; even the root user cannot modify it without disabling system protections.
- `Users`: The home base for individual user accounts. Inside, you'll find folders for each user (e.g., `/Users/admin`) containing their personal documents, downloads, and user-specific app settings.
- `Volumes`: The mount point for all connected storage devices. When you plug in an external hard drive, a USB stick, or mount a disk image (`.dmg`), it appears as a folder inside this directory.

## Hidden & Unix-Standard Directories

- `bin` **(Binaries)**: Contains essential, basic command-line utilities needed for the system to run and boot (e.g., `ls`, `cp`, `mkdir`).
- `cores`: Reserved for "core dumps." If an application crashes severely, the system can dump its active memory state into this folder to help developers debug the issue.
- `dev` **(Devices)**: This isn't actual disk space; it's a virtual directory where every hardware device (hard drives, terminal windows, screen) is represented as a file.
- `etc`: A symbolic link (shortcut) pointing to /private/etc. It houses system-wide configuration files, like network settings and host files.
- `home`: In standard Linux, this is where user profiles live. On macOS, it is a directory used by the network automounter and is usually empty, since macOS uses /Users instead.
- `opt` **(Optional)**: Reserved for third-party software packages that aren't part of the default operating system. Package managers like Homebrew often use this space.
- `private`: A hidden directory that securely isolates the true contents of `/etc`, `/tmp`, and `/var`. macOS redirects requests to those folders here to keep the root directory uncluttered.
- `sbin` **(System Binaries)**: Similar to `bin`, but contains essential tools reserved for system administration and root tasks (e.g., disk checking or network configuration tools).
- `tmp` **(Temporary)**: A shortcut to `/private/tmp`. It holds temporary files created by running apps. These files are typically wiped out when you restart your computer.
- `usr` **(User System Resources)**: A massive directory containing user utilities, libraries, and programming files that aren't critical for basic booting but are essential for running day-to-day software.
- `var`**(Variable)**: A shortcut to `/private/var`. It holds files that frequently change in size and content while the system runs, such as system logs, print queues, and caches.

## / (Root) and ~ (Tilde)

In a Unix system, the file system is structured as an inverted tree. 

### Root (/)
The slash character represents the absolute base of this entire tree.
* Every path on the computer starts at `/`. 
* It is also a global space. Files located here affect the entire system. 

### Tilde / Home (~)
It is a shell expansion shortcut that dynamically points to the active user's home directory.
* The actual path of `~` changes depending on users.

    * For user John, `~` translates to `/Users/john`.
    * For user Sarah, `~` translates to `/Users/sarah`.
    * For Root user, `~` translates to `/var/root` (or `/root` on Linux).




