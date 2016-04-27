# https://speakerdeck.com/xavriley/dubstep-in-ruby-with-sonic-pi

DRUMS = [
  :drum_splash_hard,
  :drum_cymbal_closed,
  :drum_snare_hard,
  :drum_heavy_kick
]

NP = 1.5
N = 1
C = 0.5
D = 0.25
CP = 0.75

BPM = 120.0

def beat(tab)
  tab.each_with_index do |val, i|
    sample DRUMS[i] if val
  end
end

# reduce tabs to just essential characters
# in this case 'x', 'o', 'g', - (hyphen) and line break
# map to tabs of tabs of booleans
def drum_lines(text)
  text
  .strip
  .gsub!(/[^\-xog\n]/, '')
  .lines
  .map do |line|
    line
    .chars
    .map do |c|
      %{x o g}.include?(c)
    end
  end
end

def play_tab(drum_lines)
  tab_length = drum_lines.first.length
  tab_length.times do |i|
    beat drum_lines.map {|row| row[i] }
    sleep D
  end
end

def play_chain(song, pos)
  transpo = -2 # Bb
  song[:chains][pos].each do |phrase|
    song[:phrases][phrase[0]].each do |note|
      if note[0]
        play note[0] + phrase[1] + transpo, attack: 0, release: 0.25, cutoff: rrand(50, 65)
      else
        # nil <=> not playing anything, it's a silence
      end
      sleep note[1]
    end
  end
end

CHICKEN_BASS = {
  phrases: [
    [
      [:C2, CP], [:E2, CP], [:F2, CP], [:F2, D], [:G2, C],
      [:A2, C], [:C3, C]
    ], [
      [:C2, D], [:C2, CP], [:E2, D], [:E2, CP], [:G2, D], [:G2, CP],
      [:Eb2, D], [:E2, D], [:F2, C]
    ], [
      [nil, N], [:E2, D], [:F2, C], [:G2, N], [:G1, D],
      [:G1, D], [:A1, D], [:D2, D], [:A1, D]
    ], [
      [:C3, D], [:Bb2, C], [:G2, C], [:F2, C], [:Eb2, C], [:C2, D],
      [:Bb1, C], [nil, N]
    ]
  ], chains: [[
    [0, 0],
    [0, 0],
    [0, 0],
    [1, 0],
    [2, 5],
    [0, 5],
    [0, 4],
    [0, 9],
    [0, 2],
    [0, 2],
    [0, 2],
    [3, 12],
    [0, 0],
    [0, 0],
    [0, 0],
    [0, 0]
  ], [
    [2, 12],
    [2, 12]
  ]]
}

CHICKEN_TAB = %Q{
C |----------------|----------------|----------------|----------------|
R |x---x---x---x---|x---x---x---x---|x---x---x---x---|x---x---x---x---|
S |----o--g------o-|-o--o--g----o---|----o--g------o-|-o--o--g----o---|
B |o---------o-----|--oo----o-o-----|o---------o-----|--oo----o-o-----|
}

use_bpm BPM

live_loop :bass do
  use_synth :tb303

  play_chain(CHICKEN_BASS, 0)
end

live_loop :battery do
  play_tab(drum_lines(CHICKEN_TAB))
end
