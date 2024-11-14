s.boot;
s.quit;
s.plotTree;

/*
Example 1
*/

(
x = {
	var sig, env;
	// Because the doneAction argument defaults to 0, the synth will continue running after the envelope. There will be no sound, however.
	// It will output 0s at the audio rate, which means CPU cycles are being used.
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)


x.free;

/*
Example 2
*/

s.plotTree;
(
y = {
	var sig, env;
	// Now the server will free the synth after each envelope is concluded.
	env = Line.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)


/*
Example 3
*/

// We actually do not need to assign the synth to a variable now because the doneAction will take care of freeing the synth for us.
s.plotTree;
(
{
	var sig, env;
	// Now the server will free the synth after each envelope is concluded.
	env = Line.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)


/*
Example 4 (Silent XLine)
*/

// Try playing this synth now. You will see the synth appear in the plot tree, but you will not be able to hear anything. See note above the `XLine` call to find out why.
s.plotTree;
(
{
	var sig, env;
	// It is impossible to interpolate exponentially when including or crossing 0 in the output range.
	// XLine's start and end points to either the positive or negative range.
	bad_env = XLine.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * bad_env;
}.play;
)

/*
Example 4 (Audible XLine)
*/

// XLine sounds more natural than Line. This is because we perceive amplitude exponentially. We hear an amplitude of 0.5 as half as loud as 1. We hear 0.25 as half as loud as 0.5. The exponential line makes for a nicer-sounding fade.

// The two functions below are equivalent. In the first, we are passing dB ranges into Line.kr, and then converting the db value into an amplitude value.

// In the second function, we are passing amplitude values into XLine. There is no need to convert the output signal.

// The dB scale is great for specifying how we perceive loudness changes, so when designing volume changes over time (like fades), specifying them in dB often sounds more natural.

// The amplitude scale is what digital audio systems use to actually control the sound level directly. Amplitude values represent the raw power/height of the sound wave, and they range linearly from 0 (silence) to 1 (full signal level).
s.plotTree;
(
{
	var sig, env;
	env = Line.kr(0, -40, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env.dbamp;
}.play;
)

(
{
	var sig, env;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)


/*
Example 5 (Envelope on frequency)
*/

(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

/*
Example 6 Envelope on frequency but one cuts the other off
*/

(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 0.5, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2); // Generally you want the doneAction on the shorter action to be 0. Even better is to just make them all the same duration so the envelopes are treated as a single unit.
	sig = Pulse.ar(freq) * env;
}.play;
)

/*
Example 7: EnvGen!
*/

Env.new.plot; // Results in a simple triangle envelope


(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play
)

// Second arg (gate) needs 3 array members because first arg (envelope) has 4 stages.
// For the third arg (levelScale), positive numbers mean "segment changes slowly then quickly". Negative numbers mean "segment changes quickly then slowly". Zero means "segment changes in at a constant rate".
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -10, 0]).plot;
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [\sin, \sin, 0]).plot;

// Now we can use one of our custom envelopes instead of the default Env.new:



(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -3, 0]), gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play
)


// EnvGen's gate triggers the envelope and holds it open while > 0.
// A trigger occurs when a value changes from non-positive to positive.
// Therefore, to retrigger, you can manually set the value back to 0,
// then back to 1. But this is cumbersome.
x.set(\gate, 1);
x.set(\gate, 0);

// Instead you can use t_* arguments as trigger controls.

(
x = {
	// If you set t_gate to 0, synth will start silent.
	// If you set t_gate to 1, synth will begin producing audio.
	arg t_gate=0;
	var sig, env;
	// Because this envelope has a t_gate, it is retriggerable.
	env = EnvGen.kr(Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -3, 0]), t_gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play
)

// The trigger rate argument will create a control-rate impulse at the set value during the next control cycle (approximately 64 samples).
x.set(\t_gate, 1);

/* Example: retriggerable envelope + doneAction */


(
x = {
	arg t_gate=0;
	var sig, env;
	// Because this envelope has a t_gate, it is retriggerable.
	env = EnvGen.kr(Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -3, 0]), t_gate, doneAction:2);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) * env;
}.play
)

// Since we set doneAction to 2, the envelope is retriggerable as long as it has not completed and triggered the doneAction.
// Conceptually this seems similar to trying to use an object that has been garbage collected.
x.set(\t_gate, 1);


/* Example: ADSR */

// The documentation for EnvGen's gate argument says: this triggers the envelop and holds it open while > 0. . . . If it is a sustaining envelope (e.g. Env.adsr, Env.asr), the envelope is held open until the gate becomes 0, at which point it is released.

// In this case we are using an Env.adsr envelope, which is a sustaining envelope, so as long as gate > 0, the sustain stage of the envelope will play.

(
x = {
	arg gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	/*
	VarSaw is an audio rate signal that takes a frequency. The frequency could be a single number, or it could be a control rate signal. In this case, it takes a sin wave control-rate signal. The sign wave moves from 500 to 1000 Hz over a period of 1 second. This is kind of like combining the timbre of a saw-tooth wave with the pitch movement of a sin wave.
	*/
	sig = VarSaw.ar(SinOsc.kr(1).range(500, 1000)) * env;
}.play
)

x.set(\gate, 1);

// You can also use a trigger argument so that the release phase of the envelope is almost immediately triggered. This means the sustain portion won't ever be heard...

(
x = {
	arg t_gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, t_gate);
	sig = VarSaw.ar(SinOsc.kr(1).range(500, 1000)) * env;
}.play
)

x.set(\t_gate, 1);

// Better to use a regular gate + doneAction:


(
x = {
	arg gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(1).range(500, 1000)) * env;
}.play
)

x.set(\gate, 0);

s.scope;

// What if we add some frequency modulation? We will create a control rate signal envelope and pass it in to SinOsc.kr. Remember SinOsc.kr is what determines how much time it takes for the SinOsc control rate signal to move through the range 500-1000. We are shaping the pitch journey of the VarSaw audio signal in a different way now.


(
x = {
	arg gate = 1;
	var sig, env, freq;
	// Since the freq and env envelopes share the same gate time and the same release time, only one of them needs the doneAction argument. They are already synchronized.
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000)) * env;
}.play
)

x.set(\gate, 0);

s.scope;