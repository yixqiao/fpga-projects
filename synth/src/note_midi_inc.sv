module note_midi_inc (
    input logic [7:0] midi,
    output logic [23:0] inc
);
    always_comb begin
        case (midi)
            8'd36: inc = 24'h0057CA; // C2
            8'd37: inc = 24'h005D02; // C#2
            8'd38: inc = 24'h00628A; // D2
            8'd39: inc = 24'h006866; // D#2
            8'd40: inc = 24'h006E9B; // E2
            8'd41: inc = 24'h00752F; // F2
            8'd42: inc = 24'h007C26; // F#2
            8'd43: inc = 24'h008388; // G2
            8'd44: inc = 24'h008B5A; // G#2
            8'd45: inc = 24'h0093A4; // A2
            8'd46: inc = 24'h009C6B; // A#2
            8'd47: inc = 24'h00A5B8; // B2
            8'd48: inc = 24'h00AF93; // C3
            8'd49: inc = 24'h00BA04; // C#3
            8'd50: inc = 24'h00C513; // D3
            8'd51: inc = 24'h00D0CB; // D#3
            8'd52: inc = 24'h00DD36; // E3
            8'd53: inc = 24'h00EA5D; // F3
            8'd54: inc = 24'h00F84D; // F#3
            8'd55: inc = 24'h010710; // G3
            8'd56: inc = 24'h0116B5; // G#3
            8'd57: inc = 24'h012748; // A3
            8'd58: inc = 24'h0138D7; // A#3
            8'd59: inc = 24'h014B71; // B3
            8'd60: inc = 24'h015F26; // C4
            8'd61: inc = 24'h017407; // C#4
            8'd62: inc = 24'h018A27; // D4
            8'd63: inc = 24'h01A197; // D#4
            8'd64: inc = 24'h01BA6B; // E4
            8'd65: inc = 24'h01D4BA; // F4
            8'd66: inc = 24'h01F099; // F#4
            8'd67: inc = 24'h020E21; // G4
            8'd68: inc = 24'h022D6A; // G#4
            8'd69: inc = 24'h024E8F; // A4
            8'd70: inc = 24'h0271AD; // A#4
            8'd71: inc = 24'h0296E1; // B4
            8'd72: inc = 24'h02BE4C; // C5
            default: inc = 24'h000000;
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