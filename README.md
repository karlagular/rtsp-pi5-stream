# RTSP Camera Stream — Raspberry Pi 5

Low-latency RTSP stream using **MediaMTX** with the Pi 5's built-in `rpiCamera` source. The camera activates on-demand (only when a client connects) and the service starts automatically on boot.

## Quick Start

```bash
# 1. Download MediaMTX and apply system tuning
bash setup.sh

# 2. Install and enable the systemd service (requires sudo)
sudo bash install_service.sh
```

The stream will be available (at home 2.5 Network) at:

```
rtsp://pi.local:8554/cam
rtsp://192.168.178.68:8554/cam
```

## Playback

**FFplay (lowest latency):**
```bash
ffplay rtsp://pi.local:8554/cam -fflags nobuffer -flags low_delay -framedrop
```
for Jetson to avoid transport mismatch force TCP transport:
```bash
ffplay -rtsp_transport tcp -fflags nobuffer -flags low_delay -framedrop rtsp://192.168.178.68:8554/cam
```

**VLC:**
```bash
vlc rtsp://pi.local:8554/cam
```

**Windows PC (VLC):**
- Download [VLC](https://www.videolan.org/vlc/)
- **Media → Open Network Stream** → `rtsp://192.168.178.68:8554/cam`
- For lower latency: **Tools → Preferences → Show All → Input/Codecs → Network caching** → set to `300` ms

## Ethernet Static IP Setup

Using a direct Ethernet cable between the Raspberry Pi 5 and the Jetson Nano (or any other client) gives lower latency and higher reliability than WiFi. When connecting directly without a router or switch there is no DHCP server, so both devices need a static IP address.

### Static IP on Raspberry Pi 5 (Raspberry Pi OS)

Edit `/etc/dhcpcd.conf`:

```bash
sudo nano /etc/dhcpcd.conf
```

Add the following lines at the end of the file (replace `eth0` with your interface name if different):

```
interface eth0
static ip_address=10.0.0.1/24
```

Then reboot or restart the interface:

```bash
sudo systemctl restart dhcpcd
```

Alternatively, set the static IP through the desktop GUI: **Preferences → Network → eth0 → Edit → IPv4 → Manual** and enter `10.0.0.1` / `255.255.255.0`.

### Static IP on Jetson Nano (Ubuntu / JetPack)

**GUI method:** Open **System Settings → Network → Wired → Edit → IPv4 Settings**, set Method to **Manual**, and add:

| Address   | Netmask       | Gateway |
|-----------|---------------|---------|
| 10.0.0.2  | 255.255.255.0 | (empty) |

**Netplan method:** Edit or create `/etc/netplan/01-static.yaml`:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.0.0.2/24
```

Apply the configuration:

```bash
sudo netplan apply
```

### Streaming over the Direct Ethernet Link

Once both devices have static IPs, use the Pi's address in the stream URL:

```bash
ffplay -rtsp_transport tcp rtsp://10.0.0.1:8554/cam -fflags nobuffer -flags low_delay -framedrop
```

> **Tip:** A direct cable connection (no router) requires static IPs because there is no DHCP server to assign addresses automatically.

## Measuring Latency

**Visual clock method:**
1. Display a stopwatch/clock with milliseconds on a screen or phone
2. Point the camera at it
3. Open the stream on another device
4. Take a photo showing both the real clock and the streamed clock
5. The time difference is your end-to-end latency

**FFplay with timing info:**
```bash
ffplay -loglevel debug rtsp://192.168.178.68:8554/cam -fflags nobuffer -flags low_delay -framedrop 2>&1 | grep -i "delay\|first frame"
```

## Stream Settings

| Setting       | Value               |
|---------------|---------------------|
| Resolution    | 1920×1080           |
| Framerate     | 30 fps              |
| Codec         | H.264 (software)    |
| Profile       | Baseline            |
| Bitrate       | 4 Mbps              |
| IDR period    | 30 (1 keyframe/sec) |
| Transport     | TCP                 |
| On-demand     | Yes (10s timeout)   |

## Service Management

```bash
sudo systemctl status rtsp-stream    # Check status
sudo systemctl restart rtsp-stream   # Restart
sudo systemctl stop rtsp-stream      # Stop
sudo journalctl -u rtsp-stream -f    # Live logs
```

## Configuration

Edit `config/mediamtx.yml` to change stream settings. After editing:

```bash
sudo systemctl restart rtsp-stream
```
