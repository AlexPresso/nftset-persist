# nfset-persist

A tool to download and persist ip-lists used in an nftables set.  
The script is based on the nftables scripting API, and stores them in a `/etc/nftables` directory.

## Usage

- add `include "/etc/nftables/*.nft"` in your `/etc/nftables.conf` file
- `nfset-persist <set name> <ip-list URL>` (i.e. `nfset-persist cloudflareip4 https://www.cloudflare.com/ips-v4`)
- declare your set and use it in a rule
```
set cloudflareip4 {
    type ipv4_addr
    flags interval
    elements = $cloudflareip4
}

...

tcp dport https ip saddr @cloudflareip4 accept
```
- `systemctl reload nftables` 

## Final configuration file example

```
#!/usr/sbin/nft -f

flush ruleset

include "/etc/nftables/*.nft"

table inet firewall {
        set cloudflareip4 {
                type ipv4_addr
                flags interval
                elements = $cloudflareip4
        }
        set cloudflareip6 {
                type ipv6_addr
                flags interval
                elements = $cloudflareip6
        }

        chain input {
                type filter hook input priority 0; policy drop;

                ct state invalid drop
                ct state {established, related} accept

                iif lo accept

                tcp dport https ip saddr @cloudflareip4 accept
                tcp dport https ip6 saddr @cloudflareip6 accept
        }
        chain forward {
                type filter hook forward priority 0; policy drop;
        }
        chain output {
                type filter hook output priority 0; policy accept;
        }
}
```
