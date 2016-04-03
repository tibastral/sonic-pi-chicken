# https://speakerdeck.com/xavriley/dubstep-in-ruby-with-sonic-pi

define :wob do |note, no_of_wobs, duration|
  # using in_thread so we don't block everything
    in_thread do
    use_synth :dsaw
    lowcut = note(:E1) # ~ 40Hz
    highcut = note(:G8) # ~ 3000Hz

    duration = duration.to_f || 2.0
    bpm_scale = (60 / current_bpm).to_f
    distort = 0.2

    # scale the note length based on current tempo
    slide_duration = duration * bpm_scale

    # Distortion helps give crunch
    with_fx :distortion, distort: distort do

      # rlpf means "Resonant low pass filter"
      with_fx :rlpf, cutoff: lowcut, cutoff_slide: slide_duration do |c|
        play note, attack: 0, sustain: duration, release: 0

        c.ctl cutoff_slide: ((duration / no_of_wobs.to_f) / 2.0)

        # Playing with the cutoff gives us the wobble!
        # low cutoff    -> high cutoff        -> low cutoff
        # few harmonics -> loads of harmonics -> few harmonics
        # wwwwwww -> oooooooo -> wwwwwwww
        #
        # N.B.
        # * The note is always the same length *
        # * the no_of_wobs just specifies how many *
        # * 'wow's we fit in that space *
        no_of_wobs.times do
          c.ctl cutoff: highcut
          sleep ((duration / no_of_wobs.to_f) / 2.0)
          c.ctl cutoff: lowcut
          sleep ((duration / no_of_wobs.to_f) / 2.0)
        end
      end
    end
  end
end


def phrases
  np = 1.5
  n = 1
  c = 0.5
  d = 0.25
  cp = 0.75
  [[
    [:C2, cp], [:E2, cp], [:F2, cp], [:F2, d], [:G2, c],
    [:A2, c], [:C3, c]
  ], [
    [:C2, d], [:C2, cp], [:E2, d], [:E2, cp], [:G2, d], [:G2, cp],
    [:Eb2, d], [:E2, d], [:F2, c]
  ], [
    [nil, n], [:E2, d], [:F2, c], [:G2, n], [:G1, d],
    [:G1, d], [:A1, d], [:D2, d], [:A1, d]
  ], [
    [:C3, d], [:Bb2, c], [:G2, c], [:F2, c], [:Eb2, c], [:C2, d],
    [:Bb1, c], [nil, n]
  ]]
end

chains = [[
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

def play_chain(chain)
  transpo = -2 # Bb
  chain.each do |phrase|
    phrases[phrase[0]].each do |note|
      if note[0]
        wob note[0] + phrase[1] + transpo, 1, 0.25
      else
        # nil <=> not playing anything, it's a silence
      end
      sleep note[1]
    end
  end
end

current_bpm = 120.0
use_bpm current_bpm

live_loop :bass do
  use_synth :tb303

  play_chain(chains[0])
end


amen_tab = %Q{
C |----------------|----------------|----------------|----------x-----|
R |x-x-x-x-x-x-x-x-|x-x-x-x-x-x-x-x-|x-x-x-x-x-x-x-x-|x-x-x-x-x---x-x-|
S |----o--o-o--o--o|----o--o-o--o--o|----o--o-o----o-|-o--o--o-o----o-|
B |o-o-------oo----|o-o-------oo----|o-o-------o-----|--oo------o-----|
}

# This is a random tab for the drum intro to "Cold Sweat" by James Brown
cold_sweat_tab = %Q{
C |----------------|----------------|----------------|----------------|
hh|x---x---x---x---|x---x---x---x---|x---x---x---x---|x---x---x---x---|
S |----o--g------o-|-o--o--g----o---|----o--g------o-|-o--o--g----o---|
B |o---------o-----|--oo----o-o-----|o---------o-----|--oo----o-o-----|
  |1e+a2e+a3e+a4e+a|1e+a2e+a3e+a4e+a|1e+a2e+a3e+a4e+a|1e+a2e+a3e+a4e+a|
}

# reduce to just essential characters
# in this case 'x', 'o', 'g', - (hyphen) and line break
drum_lines = cold_sweat_tab.strip.gsub!(/[^\-xog\n]/, '')

tab = drum_lines.split(/\n+/).map {|line|
  line.chars.map do |c|
    1 if (c == 'x' || c == 'o' || c == 'g')
  end
}

# We've turned our text into an array of arrays
tab.each {|row| puts row }

define :beat do |crash, ride, snare, bass|
  sample :drum_splash_hard if crash
  sample :drum_cymbal_closed if ride
  sample :drum_snare_hard if snare
  sample :drum_heavy_kick if bass
end

# We get the number of beats
tab_length = tab.first.length

live_loop :battery do
  tab_length.times.with_index do |i|

    # the '*' here is called a splat!
    # it means we can call beat(0, 1, 0, 1)
    # instead of beat([0, 1, 0, 1])
    beat *tab.map {|row| row[i] }

    sleep 0.25

    # Make it sound like a bad drummer
    # sleep rrand(0.15, 0.35)
  end
end

# Uncomment this to see how we did
in_thread do
  #sample :loop_amen_full
end

# live_loop :guitar do
#   use_synth :tb303

#   play_chain(chains[1])
# end
