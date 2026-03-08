#!/usr/bin/env python3
"""
Generate Breathway session BGM tracks from PRD mood direction.

Outputs compressed u-law WAV files in ./music:
- breathing_session_bgm.wav (60s)
- movement_session_bgm.wav (90s)
- session_finish_bgm.wav (24s)
- default_bgm.wav (120s)
"""

from __future__ import annotations

import argparse
import math
import random
import struct
import subprocess
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path


SAMPLE_RATE = 16_000


def lowpass(state: float, sample: float, alpha: float) -> float:
    return state + alpha * (sample - state)


def pulse_gaussian(x: float, center: float, width: float) -> float:
    d = (x - center) / max(width, 1e-6)
    return math.exp(-0.5 * d * d)


def safe_envelope(t: float, duration: float, fade_in: float, fade_out: float) -> float:
    up = min(1.0, t / max(fade_in, 1e-6))
    down = min(1.0, max(0.0, duration - t) / max(fade_out, 1e-6))
    return up * down


@dataclass(frozen=True)
class TrackSpec:
    name: str
    duration: float
    mood: str


TRACK_SPECS = [
    TrackSpec("breathing_session_bgm.wav", 60.0, "breathing"),
    TrackSpec("movement_session_bgm.wav", 90.0, "movement"),
    TrackSpec("session_finish_bgm.wav", 24.0, "finish"),
    TrackSpec("default_bgm.wav", 120.0, "default"),
]


def chime_layer(t: float, events: list[tuple[float, float, float, float]]) -> float:
    value = 0.0
    for start, freq, amp, decay in events:
        dt = t - start
        if dt < 0.0 or dt > 8.0:
            continue
        value += amp * math.exp(-decay * dt) * math.sin(2.0 * math.pi * freq * dt)
    return value


def render_sample(
    t: float,
    duration: float,
    mood: str,
    rng: random.Random,
    state: dict[str, float],
) -> float:
    noise = rng.uniform(-1.0, 1.0)

    if mood == "breathing":
        swell = (
            0.56
            + 0.24 * math.sin(2.0 * math.pi * 0.10 * t + 0.6)
            + 0.14 * math.sin(2.0 * math.pi * 0.033 * t + 2.1)
        )
        swell = min(1.0, max(0.18, swell))
        state["surf"] = lowpass(state["surf"], noise, 0.060)
        state["foam"] = lowpass(state["foam"], noise, 0.180)
        ocean = state["surf"] * swell
        foam = (noise - state["foam"]) * (0.10 + 0.06 * swell)

        pad_raw = (
            math.sin(2.0 * math.pi * 174.61 * t)
            + 0.68 * math.sin(2.0 * math.pi * 220.00 * t + 0.8)
            + 0.40 * math.sin(2.0 * math.pi * 261.63 * t + 1.3)
        ) / 2.08
        state["pad"] = lowpass(state["pad"], pad_raw, 0.0042)
        breath_lfo = 0.58 + 0.42 * math.sin(2.0 * math.pi * (1.0 / 8.0) * t - math.pi / 2.0)
        sample = 0.74 * ocean + 0.18 * foam + 0.18 * state["pad"] * breath_lfo
        env = safe_envelope(t, duration, 4.0, 4.5)
        return sample * env * 0.56

    if mood == "movement":
        swell = (
            0.60
            + 0.20 * math.sin(2.0 * math.pi * 0.14 * t + 0.3)
            + 0.12 * math.sin(2.0 * math.pi * 0.052 * t + 1.8)
        )
        swell = min(1.0, max(0.22, swell))
        state["surf"] = lowpass(state["surf"], noise, 0.075)
        state["foam"] = lowpass(state["foam"], noise, 0.230)
        ocean = state["surf"] * swell
        foam = (noise - state["foam"]) * (0.13 + 0.08 * swell)

        cycle = t % 6.0
        # Sit-to-Stand rhythm hints: stand phase and sit phase peaks.
        pulse = pulse_gaussian(cycle, 0.9, 0.42) + 0.92 * pulse_gaussian(cycle, 3.9, 0.48)
        kick = math.sin(2.0 * math.pi * 92.0 * t) * pulse

        pad_raw = (
            math.sin(2.0 * math.pi * 196.00 * t)
            + 0.64 * math.sin(2.0 * math.pi * 246.94 * t + 0.9)
            + 0.36 * math.sin(2.0 * math.pi * 293.66 * t + 1.8)
        ) / 2.00
        state["pad"] = lowpass(state["pad"], pad_raw, 0.0050)
        guide = 0.70 + 0.30 * math.sin(2.0 * math.pi * (1.0 / 6.0) * t - math.pi / 2.0)
        sample = 0.66 * ocean + 0.22 * foam + 0.15 * state["pad"] * guide + 0.10 * kick
        env = safe_envelope(t, duration, 4.0, 6.0)
        return sample * env * 0.58

    if mood == "finish":
        swell = (
            0.54
            + 0.18 * math.sin(2.0 * math.pi * 0.11 * t + 1.2)
            + 0.09 * math.sin(2.0 * math.pi * 0.040 * t + 0.4)
        )
        swell = min(1.0, max(0.20, swell))
        state["surf"] = lowpass(state["surf"], noise, 0.070)
        state["foam"] = lowpass(state["foam"], noise, 0.200)
        ocean = state["surf"] * swell
        foam = (noise - state["foam"]) * (0.10 + 0.06 * swell)

        pad_raw = (
            math.sin(2.0 * math.pi * 220.00 * t)
            + 0.75 * math.sin(2.0 * math.pi * 277.18 * t + 0.5)
            + 0.45 * math.sin(2.0 * math.pi * 329.63 * t + 1.1)
        ) / 2.20
        state["pad"] = lowpass(state["pad"], pad_raw, 0.0040)

        events = [
            (0.0, 523.25, 0.36, 1.30),
            (0.8, 659.25, 0.30, 1.40),
            (1.7, 783.99, 0.30, 1.45),
            (3.0, 659.25, 0.26, 1.55),
            (5.0, 523.25, 0.24, 1.60),
            (7.8, 783.99, 0.24, 1.50),
            (10.0, 659.25, 0.22, 1.55),
            (13.0, 523.25, 0.20, 1.60),
        ]
        chime = chime_layer(t, events)
        sample = 0.58 * ocean + 0.14 * foam + 0.12 * state["pad"] + 0.24 * chime
        env = safe_envelope(t, duration, 1.8, 5.0)
        return sample * env * 0.62

    # default
    swell = (
        0.57
        + 0.22 * math.sin(2.0 * math.pi * 0.082 * t + 1.0)
        + 0.12 * math.sin(2.0 * math.pi * 0.021 * t + 2.2)
    )
    swell = min(1.0, max(0.20, swell))
    state["surf"] = lowpass(state["surf"], noise, 0.055)
    state["foam"] = lowpass(state["foam"], noise, 0.165)
    ocean = state["surf"] * swell
    foam = (noise - state["foam"]) * (0.10 + 0.05 * swell)

    pad_raw = (
        math.sin(2.0 * math.pi * 164.81 * t)
        + 0.70 * math.sin(2.0 * math.pi * 207.65 * t + 0.7)
        + 0.42 * math.sin(2.0 * math.pi * 246.94 * t + 1.6)
    ) / 2.12
    state["pad"] = lowpass(state["pad"], pad_raw, 0.0038)
    sample = 0.78 * ocean + 0.16 * foam + 0.16 * state["pad"]
    env = safe_envelope(t, duration, 6.0, 8.0)
    return sample * env * 0.54


def write_pcm_wav(path: Path, duration: float, mood: str, seed: int) -> None:
    total_frames = int(duration * SAMPLE_RATE)
    rng = random.Random(seed)
    state = {"surf": 0.0, "foam": 0.0, "pad": 0.0}

    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)

        chunk = bytearray()
        chunk_limit = 8192

        for i in range(total_frames):
            t = i / SAMPLE_RATE
            sample = render_sample(t, duration, mood, rng, state)
            sample = max(-0.96, min(0.96, sample))
            s16 = int(sample * 32767.0)
            chunk.extend(struct.pack("<h", s16))
            if len(chunk) >= chunk_limit:
                wf.writeframesraw(chunk)
                chunk.clear()

        if chunk:
            wf.writeframesraw(chunk)


def convert_to_ulaw_wav(input_pcm: Path, output_wav: Path) -> None:
    cmd = [
        "afconvert",
        str(input_pcm),
        str(output_wav),
        "-f",
        "WAVE",
        "-d",
        "ulaw",
        "-c",
        "1",
    ]
    subprocess.run(cmd, check=True)


def generate_tracks(output_dir: Path) -> list[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    written_files: list[Path] = []

    with tempfile.TemporaryDirectory(prefix="breathway_bgm_") as temp_dir:
        temp_base = Path(temp_dir)
        for idx, spec in enumerate(TRACK_SPECS):
            temp_pcm = temp_base / f"{spec.name}.pcm.wav"
            out_path = output_dir / spec.name
            write_pcm_wav(temp_pcm, spec.duration, spec.mood, seed=20260227 + idx * 17)
            convert_to_ulaw_wav(temp_pcm, out_path)
            written_files.append(out_path)

    return written_files


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Breathway BGM tracks.")
    parser.add_argument(
        "--output-dir",
        default="music",
        help="Directory where final tracks are written (default: music)",
    )
    args = parser.parse_args()

    out_dir = Path(args.output_dir)
    written = generate_tracks(out_dir)

    print("Generated tracks:")
    for path in written:
        print(f"- {path}")


if __name__ == "__main__":
    main()
