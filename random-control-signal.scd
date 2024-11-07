s.boot;


// This is a function. Functions are used for smaller examples.
(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.2, 1);
	// freq = LFNoise0.kr(8, 400, 600);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\noiseHz, exprand(5, 64));
z.free;

// Same thing as above but accomplished through a SynthDef.

(
SynthDef.new(\sineTest, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.2, 1);
	// freq = LFNoise0.kr(8, 400, 600);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sineTest, [\noiseHz, 32]);
x.set(\noiseHz, 12);
x.free;