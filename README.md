# RTSP Camera Stream — Raspberry Pi 5

Low-latency RTSP stream using **MediaMTX** with the Pi 5's built-in `rpiCamera` source. The camera activates on-demand (only when a client connects) and the service starts automatically on boot.

## Quick Start

```bash
# 1. Download MediaMTX and apply system tuning
bash setup.sh

# 2. Install and enable the systemd service (requires sudo)
sudo bash install_service.sh
```

The stream will be available at:

```
rtsp://pi.local:8554/cam
rtsp://192.168.178.68:8554/cam
```

## Playback

**FFplay (lowest latency):**
```bash
ffplay rtsp://pi.local:8554/cam -fflags nobuffer -flags low_delay -framedrop
```

**VLC:**
```bash
vlc rtsp://pi.local:8554/cam
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
