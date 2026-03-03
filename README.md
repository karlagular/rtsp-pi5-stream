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

**Windows PC (VLC):**
- Download [VLC](https://www.videolan.org/vlc/)
- **Media → Open Network Stream** → `rtsp://192.168.178.68:8554/cam`
- For lower latency: **Tools → Preferences → Show All → Input/Codecs → Network caching** → set to `300` ms

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
