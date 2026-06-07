module note_lut (
    input logic clk, rst,
    input logic [7:0] scancode,
    input logic valid,
    output logic [23:0] inc,
    output logic gate
);
    logic break_pending;
    logic [7:0] current_key;

    always_ff @(posedge clk) begin
        if (rst) begin
            break_pending <= 0;
            gate <= 0;
            inc  <= 0;
            current_key <= '0;
        end else if (valid) begin
            if (scancode == 8'hF0) begin
                break_pending <= 1;         // next byte is a release
            end else begin
                break_pending <= 0;
                if (break_pending) begin
                    if (scancode == current_key)
                        gate <= 0;              // key released — kill gate
                end else begin
                    // look up inc from LUT
                    case (scancode)
                        8'h1C: inc <= 24'h01E9B0; // A  → C4  261.6 Hz
                        8'h1B: inc <= 24'h0205A0; // S  → D4
                        8'h23: inc <= 24'h023F00; // D  → E4
                        8'h2B: inc <= 24'h025A00; // F  → F4
                        8'h34: inc <= 24'h027F00; // G  → G4
                        8'h33: inc <= 24'h02BB00; // H  → A4  440 Hz
                        8'h3B: inc <= 24'h030C00; // J  → B4
                        8'h42: inc <= 24'h03D360; // K  → C5
                        default: ; // unknown key, don't change note
                    endcase
                    current_key <= scancode;
                    gate <= 1;
                end
            end
        end
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