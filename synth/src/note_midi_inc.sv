module note_midi_inc (
    input logic [7:0] midi,
    input logic [1:0] detune,
    output logic [23:0] inc
);
    // Detune: 00 (normal), 01 (+20 cents), 10 (-20 cents)
    always_comb begin
        case (detune)
            2'b00: begin // normal
                case (midi)
                    8'd24: inc = 24'h002BE5; // C1
                    8'd25: inc = 24'h002E81; // C#1
                    8'd26: inc = 24'h003145; // D1
                    8'd27: inc = 24'h003433; // D#1
                    8'd28: inc = 24'h00374D; // E1
                    8'd29: inc = 24'h003A97; // F1
                    8'd30: inc = 24'h003E13; // F#1
                    8'd31: inc = 24'h0041C4; // G1
                    8'd32: inc = 24'h0045AD; // G#1
                    8'd33: inc = 24'h0049D2; // A1
                    8'd34: inc = 24'h004E36; // A#1
                    8'd35: inc = 24'h0052DC; // B1
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
                    8'd73: inc = 24'h02E80F; // C#5
                    8'd74: inc = 24'h03144D; // D5
                    8'd75: inc = 24'h03432D; // D#5
                    8'd76: inc = 24'h0374D7; // E5
                    8'd77: inc = 24'h03A974; // F5
                    8'd78: inc = 24'h03E133; // F#5
                    8'd79: inc = 24'h041C42; // G5
                    8'd80: inc = 24'h045AD4; // G#5
                    8'd81: inc = 24'h049D1E; // A5
                    8'd82: inc = 24'h04E35A; // A#5
                    8'd83: inc = 24'h052DC3; // B5
                    8'd84: inc = 24'h057C98; // C6
                    8'd85: inc = 24'h05D01E; // C#6
                    8'd86: inc = 24'h06289B; // D6
                    8'd87: inc = 24'h06865B; // D#6
                    8'd88: inc = 24'h06E9AE; // E6
                    8'd89: inc = 24'h0752E9; // F6
                    8'd90: inc = 24'h07C266; // F#6
                    8'd91: inc = 24'h083884; // G6
                    8'd92: inc = 24'h08B5A8; // G#6
                    8'd93: inc = 24'h093A3D; // A6
                    8'd94: inc = 24'h09C6B4; // A#6
                    8'd95: inc = 24'h0A5B86; // B6
                    8'd96: inc = 24'h0AF931; // C7
                    default: inc = 24'h000000;
                endcase
            end
            2'b01: begin // +20 cents
                case (midi)
                    8'd24: inc = 24'h002C67; // C1
                    8'd25: inc = 24'h002F0B; // C#1
                    8'd26: inc = 24'h0031D7; // D1
                    8'd27: inc = 24'h0034CE; // D#1
                    8'd28: inc = 24'h0037F2; // E1
                    8'd29: inc = 24'h003B46; // F1
                    8'd30: inc = 24'h003ECC; // F#1
                    8'd31: inc = 24'h004288; // G1
                    8'd32: inc = 24'h00467D; // G#1
                    8'd33: inc = 24'h004AAD; // A1
                    8'd34: inc = 24'h004F1E; // A#1
                    8'd35: inc = 24'h0053D3; // B1
                    8'd36: inc = 24'h0058CF; // C2
                    8'd37: inc = 24'h005E17; // C#2
                    8'd38: inc = 24'h0063AF; // D2
                    8'd39: inc = 24'h00699C; // D#2
                    8'd40: inc = 24'h006FE4; // E2
                    8'd41: inc = 24'h00768B; // F2
                    8'd42: inc = 24'h007D98; // F#2
                    8'd43: inc = 24'h00850F; // G2
                    8'd44: inc = 24'h008CF9; // G#2
                    8'd45: inc = 24'h00955B; // A2
                    8'd46: inc = 24'h009E3D; // A#2
                    8'd47: inc = 24'h00A7A5; // B2
                    8'd48: inc = 24'h00B19D; // C3
                    8'd49: inc = 24'h00BC2D; // C#3
                    8'd50: inc = 24'h00C75E; // D3
                    8'd51: inc = 24'h00D338; // D#3
                    8'd52: inc = 24'h00DFC8; // E3
                    8'd53: inc = 24'h00ED16; // F3
                    8'd54: inc = 24'h00FB2F; // F#3
                    8'd55: inc = 24'h010A1F; // G3
                    8'd56: inc = 24'h0119F2; // G#3
                    8'd57: inc = 24'h012AB6; // A3
                    8'd58: inc = 24'h013C79; // A#3
                    8'd59: inc = 24'h014F4B; // B3
                    8'd60: inc = 24'h01633B; // C4
                    8'd61: inc = 24'h01785A; // C#4
                    8'd62: inc = 24'h018EBB; // D4
                    8'd63: inc = 24'h01A671; // D#4
                    8'd64: inc = 24'h01BF8F; // E4
                    8'd65: inc = 24'h01DA2C; // F4
                    8'd66: inc = 24'h01F65F; // F#4
                    8'd67: inc = 24'h02143E; // G4
                    8'd68: inc = 24'h0233E4; // G#4
                    8'd69: inc = 24'h02556C; // A4
                    8'd70: inc = 24'h0278F2; // A#4
                    8'd71: inc = 24'h029E95; // B4
                    8'd72: inc = 24'h02C675; // C5
                    8'd73: inc = 24'h02F0B4; // C#5
                    8'd74: inc = 24'h031D76; // D5
                    8'd75: inc = 24'h034CE2; // D#5
                    8'd76: inc = 24'h037F1F; // E5
                    8'd77: inc = 24'h03B459; // F5
                    8'd78: inc = 24'h03ECBD; // F#5
                    8'd79: inc = 24'h04287C; // G5
                    8'd80: inc = 24'h0467C8; // G#5
                    8'd81: inc = 24'h04AAD8; // A5
                    8'd82: inc = 24'h04F1E4; // A#5
                    8'd83: inc = 24'h053D2A; // B5
                    8'd84: inc = 24'h058CEA; // C6
                    8'd85: inc = 24'h05E168; // C#6
                    8'd86: inc = 24'h063AED; // D6
                    8'd87: inc = 24'h0699C3; // D#6
                    8'd88: inc = 24'h06FE3E; // E6
                    8'd89: inc = 24'h0768B2; // F6
                    8'd90: inc = 24'h07D97A; // F#6
                    8'd91: inc = 24'h0850F8; // G6
                    8'd92: inc = 24'h08CF90; // G#6
                    8'd93: inc = 24'h0955B0; // A6
                    8'd94: inc = 24'h09E3C9; // A#6
                    8'd95: inc = 24'h0A7A55; // B6
                    8'd96: inc = 24'h0B19D5; // C7
                    default: inc = 24'h000000;
                endcase
            end
            2'b10: begin // -20 cents
                case (midi)
                    8'd24: inc = 24'h002B64; // C1
                    8'd25: inc = 24'h002DF8; // C#1
                    8'd26: inc = 24'h0030B4; // D1
                    8'd27: inc = 24'h003399; // D#1
                    8'd28: inc = 24'h0036AB; // E1
                    8'd29: inc = 24'h0039EB; // F1
                    8'd30: inc = 24'h003D5D; // F#1
                    8'd31: inc = 24'h004103; // G1
                    8'd32: inc = 24'h0044E0; // G#1
                    8'd33: inc = 24'h0048F9; // A1
                    8'd34: inc = 24'h004D50; // A#1
                    8'd35: inc = 24'h0051E9; // B1
                    8'd36: inc = 24'h0056C7; // C2
                    8'd37: inc = 24'h005BF0; // C#2
                    8'd38: inc = 24'h006168; // D2
                    8'd39: inc = 24'h006733; // D#2
                    8'd40: inc = 24'h006D56; // E2
                    8'd41: inc = 24'h0073D6; // F2
                    8'd42: inc = 24'h007AB9; // F#2
                    8'd43: inc = 24'h008205; // G2
                    8'd44: inc = 24'h0089C1; // G#2
                    8'd45: inc = 24'h0091F2; // A2
                    8'd46: inc = 24'h009A9F; // A#2
                    8'd47: inc = 24'h00A3D1; // B2
                    8'd48: inc = 24'h00AD8F; // C3
                    8'd49: inc = 24'h00B7E1; // C#3
                    8'd50: inc = 24'h00C2D0; // D3
                    8'd51: inc = 24'h00CE65; // D#3
                    8'd52: inc = 24'h00DAAB; // E3
                    8'd53: inc = 24'h00E7AC; // F3
                    8'd54: inc = 24'h00F573; // F#3
                    8'd55: inc = 24'h01040B; // G3
                    8'd56: inc = 24'h011381; // G#3
                    8'd57: inc = 24'h0123E3; // A3
                    8'd58: inc = 24'h01353F; // A#3
                    8'd59: inc = 24'h0147A2; // B3
                    8'd60: inc = 24'h015B1E; // C4
                    8'd61: inc = 24'h016FC2; // C#4
                    8'd62: inc = 24'h0185A0; // D4
                    8'd63: inc = 24'h019CCB; // D#4
                    8'd64: inc = 24'h01B557; // E4
                    8'd65: inc = 24'h01CF58; // F4
                    8'd66: inc = 24'h01EAE5; // F#4
                    8'd67: inc = 24'h020816; // G4
                    8'd68: inc = 24'h022703; // G#4
                    8'd69: inc = 24'h0247C7; // A4
                    8'd70: inc = 24'h026A7D; // A#4
                    8'd71: inc = 24'h028F44; // B4
                    8'd72: inc = 24'h02B63B; // C5
                    8'd73: inc = 24'h02DF83; // C#5
                    8'd74: inc = 24'h030B3F; // D5
                    8'd75: inc = 24'h033996; // D#5
                    8'd76: inc = 24'h036AAD; // E5
                    8'd77: inc = 24'h039EB0; // F5
                    8'd78: inc = 24'h03D5CA; // F#5
                    8'd79: inc = 24'h04102C; // G5
                    8'd80: inc = 24'h044E06; // G#5
                    8'd81: inc = 24'h048F8D; // A5
                    8'd82: inc = 24'h04D4FB; // A#5
                    8'd83: inc = 24'h051E89; // B5
                    8'd84: inc = 24'h056C76; // C6
                    8'd85: inc = 24'h05BF06; // C#6
                    8'd86: inc = 24'h06167F; // D6
                    8'd87: inc = 24'h06732B; // D#6
                    8'd88: inc = 24'h06D55A; // E6
                    8'd89: inc = 24'h073D60; // F6
                    8'd90: inc = 24'h07AB95; // F#6
                    8'd91: inc = 24'h082058; // G6
                    8'd92: inc = 24'h089C0C; // G#6
                    8'd93: inc = 24'h091F1B; // A6
                    8'd94: inc = 24'h09A9F5; // A#6
                    8'd95: inc = 24'h0A3D11; // B6
                    8'd96: inc = 24'h0AD8ED; // C7
                    default: inc = 24'h000000;
                endcase
            end
            default: inc = 24'h000000;
        endcase
    end
endmodule

/*
#!/usr/bin/env python3
"""
Generates SystemVerilog code for the `always_comb` block of note_midi_inc.

Produces a top-level `case (detune)` (00 = normal, 01 = +20 cents,
10 = -20 cents), each containing a `case (midi)` with 24-bit DDS phase
increments for MIDI notes C1 (24) through C7 (96).

All pitch/cents math is done here in Python; the generated SV is just
table lookups. Run this script and paste stdout into the module.
"""

SAMPLE_RATE = 48828
PHASE_BITS = 24

A4_FREQ = 440.0
A4_MIDI = 69  # MIDI note number for A4 -> matches midi 60 == C4

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

MIDI_LOW = 24   # C1
MIDI_HIGH = 96  # C7

# detune encoding -> cents offset, and a comment label for the SV case arm
DETUNE_CASES = [
    ("2'b00", 0, "normal"),
    ("2'b01", 20, "+20 cents"),
    ("2'b10", -20, "-20 cents"),
]


def midi_to_name_octave(midi: int):
    """midi 60 -> ('C', 4), matching A4 = midi 69 convention."""
    name = NOTE_NAMES[midi % 12]
    octave = (midi // 12) - 1
    return name, octave


def midi_to_freq(midi: int, cents: float = 0.0) -> float:
    semitones_from_a4 = (midi - A4_MIDI) + (cents / 100.0)
    return A4_FREQ * (2.0 ** (semitones_from_a4 / 12.0))


def freq_to_inc(freq: float) -> int:
    inc = round(freq / SAMPLE_RATE * (2 ** PHASE_BITS))
    if not (0 <= inc <= 0xFFFFFF):
        raise ValueError(f"phase increment {inc} out of 24-bit range for freq={freq}")
    return inc


def gen_midi_case(cents: float, indent: str) -> str:
    lines = [f"{indent}case (midi)"]
    for midi in range(MIDI_LOW, MIDI_HIGH + 1):
        name, octave = midi_to_name_octave(midi)
        inc = freq_to_inc(midi_to_freq(midi, cents))
        lines.append(f"{indent}    8'd{midi}: inc = 24'h{inc:06X}; // {name}{octave}")
    lines.append(f"{indent}    default: inc = 24'h000000;")
    lines.append(f"{indent}endcase")
    return "\n".join(lines)


def gen_always_comb() -> str:
    lines = ["    always_comb begin", "        case (detune)"]
    for detune_val, cents, label in DETUNE_CASES:
        lines.append(f"            {detune_val}: begin // {label}")
        lines.append(gen_midi_case(cents, indent="                "))
        lines.append("            end")
    # default (e.g. 2'b11): fall back to normal tuning
    lines.append("            default: begin // normal")
    lines.append(gen_midi_case(0, indent="                "))
    lines.append("            end")
    lines.append("        endcase")
    lines.append("    end")
    return "\n".join(lines)


if __name__ == "__main__":
    print(gen_always_comb())
*/