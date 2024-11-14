s.boot;
s.quit;
s.scope;


(
SynthDef.new(\wigglySynth, {
	var sig1;
	sig1 = SinOsc.ar(440, 0.8, SinOsc.kr(4, 0.5, 0.12));
	Out.ar(0, sig1)
}).add
)

x = Synth.new(\wigglySynth)
