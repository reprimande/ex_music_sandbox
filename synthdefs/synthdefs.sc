s.boot;
(
SynthDef(\kick01, {|amp=0.6, dur=0.8|
  var env1, env2, out;
  env1 = EnvGen.ar(Env.perc(0.001, dur, 1, -4), doneAction:2);
  env2 = EnvGen.ar(Env.new([6000, 300, 20], [0.001, 0.2], [-4, -5]));
  out = SinOsc.ar(env2, 0) * env1;
  out = out * amp;
  Out.ar(0, out.dup);
}).store;

SynthDef(\snare01, {|amp=0.5, dur=0.3|
  var env1, env2, out;
  env1 = EnvGen.ar(Env.perc(0.001, dur, 1, -4), doneAction:2);
  env2 = EnvGen.ar(Env.perc(0.001, 0.02, 3000, -4));
  out = LFPulse.ar(env2, 0, 0.5);
  out = out + BPF.ar(ClipNoise.ar(1), 7000, 0.5) * env1 * amp;
  Out.ar(0, out.dup);
}).store;

SynthDef(\hat01, {|amp=0.1, dur=0.05|
  var env1, env2, out;
  env1 = EnvGen.ar(Env.perc(0.0001, dur, 1, -4), doneAction:2);
  out = RHPF.ar(ClipNoise.ar(1), 10000, 0.08) * env1 * amp;
  Out.ar(0, out.dup);
}).store;

SynthDef(\fmchord01, {|freq=440, amp=0.2, dur=2|
  var index_env, amp_env, out;
  index_env = EnvGen.ar(Env.perc(0.0001, 0.2, 1, -4));
  amp_env = EnvGen.ar(Env.perc(0.0001, 1, dur, -4), doneAction:2);
  out = PMOsc.ar(freq, freq * 1.02, (index_env * 2)) * amp_env;
  out = FreeVerb.ar(out.dup, 0.5, 0.8, 0.9);
  Out.ar(0, out * amp);
}).store;

SynthDef(\pad01, {|freq=440, amp=0.5, dur=2|
  var env1, out;
  env1 = EnvGen.ar(Env.linen(4, 0.3, 4, 1, -4), doneAction:2);
  out = Pulse.ar([freq, freq * 1.01, freq * 0.99], SinOsc.kr(1, 0, 0.3, 1.5), env1);
  out = RLPF.ar(out, freq * 1.1, 0.9);
  out = FreeVerb.ar(out.dup, 0.8, 0.8, 0.9);
  Out.ar(0, out * 0.3);
}).store;
)
