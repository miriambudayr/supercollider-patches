s.boot;
s.quit;
s.scope;



(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	// short pulses; multiplied by 0.75 just to take the volume down
	// a bit.
	amp1 = SinOsc.kr(4, 0.5, 0.12) * 0.75;
	// 0.5 phase so the two amps are out of phase relative to one another
	amp2 = SinOsc.kr(4, 0, 0.12) * 0.75;
	// LFNoise0 will output random overtones of a given fundamental.
	freq1 = LFNoise0.kr(ampHz).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(ampHz).exprange(fund, fund*maxPartial).round(fund);
	// usually pulse ranges from 0-1, so adding 1 to it makes its range from 1-2.
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add
)

x = Synth.new(\pulseTest);
x.set(\width, 0.4);
x = Synth.new(\pulseTest, [\ampHz, 3.3]);

// Second experiment
s.scope;

(
SynthDef.new(\pulseTest2, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5, moog_freq=100, moog_gain = 2, moog_reset = 0, moog_mul = 1, moog_add = 0;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	freq1 = LFNoise0.kr(ampHz).exprange(fund, fund*maxPartial).round(fund).poll;
	sig1 = Pulse.ar(freq1, width);
	sig1 = MoogFF.ar(sig1, moog_freq, moog_gain, moog_reset, moog_mul, moog_add);
	Out.ar(0, sig1);
}).add
)

x = Synth.new(\pulseTest2);

x.set(\moog_freq, SinOsc.kr(LFNoise0.kr(0.42).range(0.001, 2.2)).range(30, 4200));
x.set(\moog_mul, 1);