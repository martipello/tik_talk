#include <flutter/runtime_effect.glsl>

// Renders the liquid body for the "Fluid Glass 2" watch face. The surface
// shape is NOT computed here - it's handed down each frame as the current
// state of a damped-oscillator slosh simulation (see _SloshSimulation in
// fluid_glass2_face.dart), so the shader is a pure function of that state
// rather than its own animation clock (uTime only drives the surface-noise
// flicker, not the slosh itself). uMode1/uMode2 are each a damped
// oscillator's (sine, cosine) state, combined into one slowly-drifting wave;
// uMode3 is a radial ripple (amplitude, phase) that reads as an expanding
// splash ring right after a "pour" event and decays to ~0 at rest.
uniform vec2 uSize;
uniform float uFillLevel;
uniform vec2 uMode1;
uniform vec2 uMode2;
uniform vec2 uMode3;
uniform vec4 uBaseColor;
uniform float uTime;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// A single thin horizontal-ish strand: a soft (Gaussian) line whose vertical
// position wanders around `centerY` and whose width breathes between
// `widthMin` and `widthMin + widthBase`, both as a function of x (and time,
// so it's not static). Used several times at once with different
// frequencies/phases - see uses below - so the strands drift in and out of
// alignment with each other: where a few line up, the stack reads as a
// thicker patch of froth; where they fan apart, each shows as its own
// hairline. That's what gives the band varying thickness along its length
// instead of a fixed-width stripe.
float thinLine(float y, float x, float centerY, float freqY, float phaseY, float ampY,
    float freqW, float phaseW, float widthBase, float widthMin, float speedY, float speedW) {
  float offsetY = ampY * sin(freqY * x + phaseY + uTime * speedY);
  float width = widthMin + widthBase * (0.5 + 0.5 * sin(freqW * x + phaseW + uTime * speedW));
  float d = y - (centerY + offsetY);
  return exp(-(d * d) / (2.0 * width * width));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  // Orb-local normalized coords: -1..1, y-up.
  vec2 n = vec2(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0);

  // Two independent waves - background and foreground - that are free to
  // cross each other (even repeatedly, like a figure-8) because they're
  // built from different combinations of the same two oscillators (see
  // below). The one thing they're NOT free to do is disagree about where
  // they start and stop: the orb is a round bowl, and the leftmost/
  // rightmost points of that circle (n.x = -1 and n.x = 1) are the same
  // physical rim for both of them - one continuous loop that happens to
  // cross itself in the middle, not two separate arcs with a gap between
  // their ends. sqrt(1 - x*x) is the circle's own silhouette (the
  // y = +-sqrt(r^2-x^2) you'd get looking at a circle edge-on), so
  // multiplying both waves by it pins both of them - together - to height
  // 0 (exactly baseY) at both edges, regardless of amplitude, frequency or
  // phase, instead of leaving it to coincidence of whatever the mode
  // coefficients happen to be this frame.
  float waveEnvelope = sqrt(max(0.0, 1.0 - n.x * n.x));

  // A near-empty orb is too thin a film of water to credibly swing a
  // full-height wave, no matter how much energy a poke() just dumped into
  // the simulation - wave height (and ripple, and froth turbulence/
  // brightness further below) all fade out as uFillLevel drops below a
  // quarter full, instead of reading as a tall wave riding on almost no
  // water.
  float waterAmount = smoothstep(0.0, 0.25, uFillLevel);

  const float kWaveBackground = 2.2;
  vec2 backgroundCoef = vec2(uMode1.x + uMode2.x, uMode1.y + uMode2.y);
  float waveBackground = waveEnvelope * waterAmount *
      (backgroundCoef.x * sin(kWaveBackground * n.x) + backgroundCoef.y * cos(kWaveBackground * n.x));

  // Foreground: a different linear combination of the same two oscillators
  // (uMode1/uMode2 are independently detuned - different stiffness/damping,
  // see _SloshSimulation) rather than a spatial-only phase shift of the
  // background, so it genuinely beats at a different rate over time instead
  // of just looking like a repositioned copy of the background's motion.
  const float kWaveForeground = 2.6;
  vec2 foregroundCoef = vec2(uMode1.x * 0.5 - uMode2.x * 0.9, uMode1.y * 0.5 - uMode2.y * 0.9);
  float waveForeground = waveEnvelope * waterAmount *
      (foregroundCoef.x * sin(kWaveForeground * n.x + 0.9) + foregroundCoef.y * cos(kWaveForeground * n.x + 0.9));

  float r = length(n);
  float ripple = waterAmount * uMode3.x * cos(r * 6.0 - uMode3.y) * exp(-r * 2.6);

  float baseY = 1.0 - uFillLevel;
  float backgroundY = baseY - waveBackground - ripple;
  float foregroundY = baseY - waveForeground - ripple;

  // The water's actual silhouette is whichever of the two curves is
  // currently higher (smaller y) at this x - the outer envelope of the
  // two - so the fill always extends up to meet whichever curve is
  // "outside" at that point, instead of being pinned to a single curve
  // that the other is free to cross above and be left floating in mid-air
  // with nothing filled beneath it. Wherever the other curve dips inside
  // the fill instead, it just reads as a froth vein glimpsed under the
  // surface - still correct, not a bug.
  float fillY = min(backgroundY, foregroundY);

  // No early `return`s (Flutter's shader compiler has had trouble with
  // multiple return statements inside main() on some backends) - instead
  // every layer below is composited into `result` with a standard "over"
  // blend, unconditionally.
  // Same waterAmount gate as the wave height above, applied here to froth
  // turbulence/brightness too.
  float tiltEnergy = length(uMode1) + length(uMode2);
  float agitation = clamp(tiltEnergy + abs(uMode3.x) * 2.0, 0.0, 2.0) * waterAmount;
  float alpha = uBaseColor.a;

  // Body: depth-shaded from the water's actual silhouette down to the
  // bottom of the orb. bodyMask (not a branch) fades this in across fillY
  // so it still composites cleanly with the layers below.
  float depth = clamp((uv.y - fillY) / max(1.0 - fillY, 0.001), 0.0, 1.0);
  vec3 deepColor = uBaseColor.rgb * 0.68;
  vec3 bodyColor = mix(uBaseColor.rgb * 0.92, deepColor, depth * 0.7);

  // Marble vein: one differently-coloured streak wandering through the
  // middle of the body. The colour is the base colour with its channels
  // rotated (rather than just lightened/darkened) so it reads as a distinct
  // vein rather than a highlight, while still clearly belonging to the same
  // liquid. Its own wobble is pinned by the same circle envelope as the
  // crest waves above, so it reads as another ellipse running through the
  // bowl rather than an arbitrary squiggle that ignores the rim.
  //
  // Deliberately anchored to baseY (the resting fill level), not fillY (the
  // current, wavy silhouette): fillY swings with every crest/trough of the
  // surface, and "48% of the way from fillY to the bottom" would drag the
  // vein up and down right along with it - wherever the crest happened to
  // peak, the vein would end up hugging it too, instead of running through
  // the middle of the body at a stable depth with its own independent life.
  float veinCenterY = mix(baseY, 1.0, 0.48);
  float veinOffset = waveEnvelope *
      (0.05 * sin(2.1 * n.x + uTime * 0.35 + 1.4) + 0.02 * sin(5.0 * n.x - uTime * 0.2));
  float veinWidth = 0.012 + 0.008 * (0.5 + 0.5 * sin(3.3 * n.x + uTime * 0.5));
  float veinD = uv.y - (veinCenterY + veinOffset);
  float veinGlow = exp(-(veinD * veinD) / (2.0 * veinWidth * veinWidth));
  // Channel rotation alone degenerates for grayscale accents - rotating
  // (0,0,0) or (1,1,1) is a no-op, so a black or white base left the vein
  // completely invisible (identical to the body it's supposed to cut
  // through). Pulling it toward whichever of black/white contrasts with the
  // base's own luminance guarantees it's always visible, while still
  // starting from the hue-rotated colour so it keeps some relation to the
  // liquid's own colour for non-grayscale accents instead of just being a
  // flat black/white line.
  vec3 veinHue = vec3(uBaseColor.g, uBaseColor.b, uBaseColor.r);
  float baseLuminance = dot(uBaseColor.rgb, vec3(0.299, 0.587, 0.114));
  vec3 veinColor = mix(veinHue, vec3(1.0 - baseLuminance), 0.6);
  bodyColor = mix(bodyColor, veinColor, veinGlow * 0.55);

  float bodyMask = smoothstep(fillY - 0.01, fillY + 0.01, uv.y);
  vec4 result = vec4(bodyColor * bodyMask * alpha, bodyMask * alpha);

  // Background and foreground froth: strands riding on each curve. Both
  // computed (still own frequencies/phases, so they don't read as
  // duplicates), but combined with max() rather than composited one after
  // the other - compositing both independently would double up anywhere
  // they overlap (which is most of the time right as the sim starts, before
  // the two curves have drifted apart), reading as the glow "multiplying"
  // itself. max() keeps a single glow wherever either strand is bright,
  // instead of stacking them. Toned down overall (0.3 base, 0.08 from
  // agitation - was 0.75/0.15): a hint of light catching the crest, not a
  // wash of white, especially right at a poke when agitation spikes.
  float backgroundFroth = 0.0;
  backgroundFroth += thinLine(uv.y, n.x, backgroundY, 2.9, 1.1, 0.013, 4.8, 2.0, 0.008, 0.0022, 0.4, 0.75);
  backgroundFroth += thinLine(uv.y, n.x, backgroundY, 3.8, 2.6, 0.009, 6.1, 0.9, 0.006, 0.0018, 0.55, 0.95);
  backgroundFroth += thinLine(uv.y, n.x, backgroundY, 2.2, 4.0, 0.016, 3.6, 3.4, 0.009, 0.0024, 0.3, 0.65);
  backgroundFroth = clamp(backgroundFroth, 0.0, 1.0);

  float froth = 0.0;
  froth += thinLine(uv.y, n.x, foregroundY, 3.1, 0.3, 0.014, 5.2, 0.6, 0.009, 0.0022, 0.5, 0.9);
  froth += thinLine(uv.y, n.x, foregroundY, 4.4, 1.9, 0.010, 6.7, 2.3, 0.007, 0.0018, 0.65, 1.1);
  froth += thinLine(uv.y, n.x, foregroundY, 2.7, 2.8, 0.017, 4.3, 4.1, 0.010, 0.0022, 0.4, 0.8);
  froth += thinLine(uv.y, n.x, foregroundY, 5.3, 4.2, 0.008, 7.4, 1.1, 0.006, 0.0016, 0.6, 1.0);
  froth = clamp(froth, 0.0, 1.0);

  float combinedFroth = max(backgroundFroth, froth);
  float noise = hash(floor(n * vec2(140.0, 200.0)) + floor(uTime * 6.0));
  float turbulence = (noise - 0.5) * (0.05 + agitation * 0.08) * combinedFroth;
  vec3 frothColor = vec3(1.0) + turbulence;
  float frothAlpha = combinedFroth * (0.3 + agitation * 0.08) * alpha;
  result.rgb = frothColor * frothAlpha + result.rgb * (1.0 - frothAlpha);
  result.a = frothAlpha + result.a * (1.0 - frothAlpha);

  fragColor = result;
}
