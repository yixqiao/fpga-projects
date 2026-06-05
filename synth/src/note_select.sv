module note_select (
    input logic [1:0] note_sel,
    output logic [23:0] inc
);
    // inc = f / f_sample * 2^24
    // f_sample = 48828
    always_comb begin
        case (note_sel)
            2'b00: inc = 24'd22_474; // C2
            2'b01: inc = 24'd89_894; // C4
            2'b10: inc = 24'd134_689; // G4
            2'b11: inc = 24'd179_788; // C5
        endcase
    end
endmodule

/*
import sys

SAMPLE_RATE = 48828
PHASE_BITS = 24

# A4 = 440 Hz, standard concert tuning
A4_FREQ = 440.0

NOTE_SEMITONES = {
    'C': -9, 'C#': -8, 'Db': -8,
    'D': -7, 'D#': -6, 'Eb': -6,
    'E': -5,
    'F': -4, 'F#': -3, 'Gb': -3,
    'G': -2, 'G#': -1, 'Ab': -1,
    'A':  0, 'A#':  1, 'Bb':  1,
    'B':  2,
}

def parse_note(s):
    # Split into name + octave, e.g. "C#4" -> ("C#", 4), "Bb3" -> ("Bb", 3)
    for i, c in enumerate(s):
        if c.isdigit() or (c == '-' and i > 0):
            name = s[:i]
            octave = int(s[i:])
            break
    else:
        raise ValueError(f"Can't parse note: {s}")
    if name not in NOTE_SEMITONES:
        raise ValueError(f"Unknown note name: {name}")
    return name, octave

def note_to_freq(name, octave):
    semitones_from_a4 = NOTE_SEMITONES[name] + (octave - 4) * 12
    return A4_FREQ * (2 ** (semitones_from_a4 / 12))

def freq_to_inc(freq):
    return round(freq / SAMPLE_RATE * (2 ** PHASE_BITS))

if __name__ == "__main__":
    notes = ["C2", "C4", "G4", "C5"]
    for note_str in notes:
        name, octave = parse_note(note_str)
        freq = note_to_freq(name, octave)
        inc = freq_to_inc(freq)
        print(f"{name}{octave}: freq={freq:.3f} Hz, inc={inc} (0x{inc:06X})")
*/