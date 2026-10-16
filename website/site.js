// Suga website: footer year, and the hero's light show (a quiet take on the
// app's Disco mode). Kept in a file, not inline, so the CSP can forbid inline
// scripts.

document.querySelectorAll("[data-year]").forEach((el) => {
  el.textContent = String(new Date().getFullYear());
});

(() => {
  const canvas = document.querySelector(".stage");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const anchor = document.querySelector(".hero-visual") || canvas;
  const still = window.matchMedia("(prefers-reduced-motion: reduce)");

  // The app's Neon palette (lib/visuals/palette.dart).
  const palette = ["#FF2BD6", "#7A2BFF", "#2B8CFF", "#00F0FF", "#39FF88"];
  const beams = 8;
  const beatMs = 500; // 120 BPM

  let width = 0;
  let height = 0;
  let center = { x: 0, y: 0 };
  let running = false;
  let visible = true;
  let start = performance.now();

  function resize() {
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    const box = canvas.getBoundingClientRect();
    width = box.width;
    height = box.height;
    canvas.width = Math.round(width * ratio);
    canvas.height = Math.round(height * ratio);
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    const a = anchor.getBoundingClientRect();
    center = { x: a.left + a.width / 2 - box.left, y: a.top + a.height * 0.45 - box.top };
  }

  function draw(now) {
    const t = (now - start) / 1000;
    const beat = Math.floor((now - start) / beatMs);
    // 1 on the beat, easing to 0 before the next. Kept faint: this is
    // atmosphere behind text, not a strobe.
    const pulse = Math.pow(1 - ((now - start) % beatMs) / beatMs, 3);
    const reach = Math.hypot(width, height);

    ctx.clearRect(0, 0, width, height);
    ctx.globalCompositeOperation = "lighter";

    for (let i = 0; i < beams; i++) {
      const spin = t * (i % 2 ? -0.11 : 0.15);
      const angle = spin + (i * Math.PI * 2) / beams;
      const band = 0.5 + 0.5 * Math.sin(t * (1.3 + i * 0.37) + i);
      const spread = 0.1 + 0.08 * band;
      const alpha = 0.07 + 0.08 * band + 0.06 * pulse;
      const color = palette[(i + beat) % palette.length];

      const gradient = ctx.createRadialGradient(center.x, center.y, 0, center.x, center.y, reach * 0.75);
      gradient.addColorStop(0, hexAlpha(color, alpha));
      gradient.addColorStop(1, hexAlpha(color, 0));
      ctx.fillStyle = gradient;
      ctx.beginPath();
      ctx.moveTo(center.x, center.y);
      ctx.arc(center.x, center.y, reach, angle - spread / 2, angle + spread / 2);
      ctx.closePath();
      ctx.fill();
    }

    const glow = 120 + 40 * pulse;
    const core = ctx.createRadialGradient(center.x, center.y, 0, center.x, center.y, glow);
    core.addColorStop(0, `rgba(230, 238, 244, ${0.18 + 0.08 * pulse})`);
    core.addColorStop(1, "rgba(230, 238, 244, 0)");
    ctx.fillStyle = core;
    ctx.beginPath();
    ctx.arc(center.x, center.y, glow, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalCompositeOperation = "source-over";
  }

  function hexAlpha(hex, alpha) {
    const n = parseInt(hex.slice(1), 16);
    return `rgba(${n >> 16}, ${(n >> 8) & 255}, ${n & 255}, ${alpha.toFixed(3)})`;
  }

  function frame(now) {
    if (!running) return;
    draw(now);
    requestAnimationFrame(frame);
  }

  function update() {
    const shouldRun = visible && !document.hidden && !still.matches;
    if (shouldRun && !running) {
      running = true;
      requestAnimationFrame(frame);
    } else if (!shouldRun) {
      running = false;
      // Reduced motion (or paused): leave one calm frame in place.
      draw(start + 1200);
    }
  }

  resize();
  update();
  window.addEventListener("resize", () => { resize(); if (!running) draw(start + 1200); });
  document.addEventListener("visibilitychange", update);
  still.addEventListener("change", update);
  new IntersectionObserver(([entry]) => { visible = entry.isIntersecting; update(); }).observe(canvas);
})();
