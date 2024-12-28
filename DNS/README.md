# DNS Management Script - Bash Implementation

## Overview

This project is a Bash script designed for automating DNS server management tasks, including adding, removing, and searching for DNS records and domains. It is optimized for environments where quick and reliable DNS configuration is essential.

## Features

- Add New Records: Supports multiple record types such as A, AAAA, CNAME, MX, SPF, DKIM, etc.

- Remove Records: Safely removes DNS records.

- Search Capabilities: Search for specific records or domains to verify their existence.

- Add New Domains: Easily create new DNS zones and associated files.

- Serial Number Management: Automatically updates the serial number in DNS zone files to ensure changes are recognized by DNS resolvers.

- Validation: Validates IP addresses and other input to prevent configuration errors.

## Prerequisites

- A Linux-based operating system with Bash installed.

- Bind DNS server installed and configured.

- Root or sudo access to the system.

- Basic understanding of DNS records and zones.

## Usage

Run the script with appropriate options and arguments to manage DNS records and domains:
```bash
./dns-management.sh [OPTIONS]

Options

-h: Display help information and usage examples.

-a: Add a new DNS record. Requires -t to specify the record type.

-t: Specify the record type (e.g., A, AAAA, CNAME, MX).

-r: Remove an existing DNS record.

-d: Add a new domain and its associated zone file.

-s: Search for a specific DNS record.

-S: Search for a specific domain.
```

Examples

Add an A record for foo.example.com:
```bash
./dns-management.sh -t A -a foo.example.com 10.20.30.40
```

Remove a record for example.com:
```bash
./dns-management.sh -r example.com 2.2.2.2
```
Add a new domain example.com:
```bash
./dns-management.sh -d example.com
```
Search for a record:
```bash
./dns-management.sh -s foo.example.com 10.20.30.40
```
Search for a domain:
```bash
./dns-management.sh -S example.com
```

## Configuration

The script interacts with DNS configuration files stored in /var/named/. Ensure the necessary permissions are set for the script to read and modify these files.

## Logs

Errors and informational messages are displayed in the terminal during execution. Consider redirecting output to a log file for auditing purposes.

## Troubleshooting

If the script fails to add or remove records, ensure the zone files exist and are writable.

Check /etc/named.conf to confirm the zones are correctly configured.

Verify the Bind DNS service is running and correctly configured.

## Future Improvements

- Implement logging to a centralized log file.

- Add support for managing DNSSEC configurations.

- Enhance validation for additional record types.


## License

This script is provided under the Apache2 License. See the LICENSE file for details.


