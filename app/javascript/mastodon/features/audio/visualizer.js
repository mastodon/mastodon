/*
Copyright (c) 2020 by Alex Permyakov (https://codepen.io/alexdevp/pen/RNELPV)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

const hex2rgba = (hex, alpha = 1) => {
  const [r, g, b] = hex.match(/\w\w/g).map(x => parseInt(x, 16));
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

export default class Visualizer {

  constructor (tickSize) {
    this.tickSize = tickSize;
  }

  setCanvas(canvas) {
    this.canvas = canvas;
    if (canvas) {
      this.context = canvas.getContext('2d');
    }
  }

  setAudioContext(context, source) {
    const analyser = context.createAnalyser();

    analyser.smoothingTimeConstant = 0.6;
    analyser.fftSize = 2048;

    source.connect(analyser);

    this.analyser = analyser;
  }

  getTickPoints (count) {
    const coords = [];

    for(let i = 0; i < count; i++) {
      const rad = Math.PI * 2 * i / count;
      coords.push({ x: Math.cos(rad), y: -Math.sin(rad) });
    }

    return coords;
  }

  drawTick (cx, cy, mainColor, x1, y1, x2, y2) {
    const dx1 = Math.ceil(cx + x1);
    const dy1 = Math.ceil(cy + y1);
    const dx2 = Math.ceil(cx + x2);
    const dy2 = Math.ceil(cy + y2);

    const gradient = this.context.createLinearGradient(dx1, dy1, dx2, dy2);

    const lastColor = hex2rgba(mainColor, 0);

    gradient.addColorStop(0, mainColor);
    gradient.addColorStop(0.6, mainColor);
    gradient.addColorStop(1, lastColor);

    this.context.beginPath();
    this.context.strokeStyle = gradient;
    this.context.lineWidth = 2;
    this.context.moveTo(dx1, dy1);
    this.context.lineTo(dx2, dy2);
    this.context.stroke();
  }

  getTicks (count, size, radius, scaleCoefficient) {
    const ticks = this.getTickPoints(count);
    const lesser = 200;
    const m = [];
    const bufferLength = this.analyser ? this.analyser.frequencyBinCount : 0;
    const frequencyData = new Uint8Array(bufferLength);
    const allScales = [];

    if (this.analyser) {
      this.analyser.getByteFrequencyData(frequencyData);
    }

    ticks.forEach((tick, i) => {
      const coef = 1 - i / (ticks.length * 2.5);

      let delta = ((frequencyData[i] || 0) - lesser * coef) * scaleCoefficient;

      if (delta < 0) {
        delta = 0;
      }

      const k = radius / (radius - (size + delta));

      const x1 = tick.x * (radius - size);
      const y1 = tick.y * (radius - size);
      const x2 = x1 * k;
      const y2 = y1 * k;

      m.push({ x1, y1, x2, y2 });

      if (i < 20) {
        let scale = delta / (200 * scaleCoefficient);
        scale = scale < 1 ? 1 : scale;
        allScales.push(scale);
      }
    });

    const scale = allScales.reduce((pv, cv) => pv + cv, 0) / allScales.length;

    return m.map(({ x1, y1, x2, y2 }) => ({
      x1: x1,
      y1: y1,
      x2: x2 * scale,
      y2: y2 * scale,
    }));
  }

  clear (width, height) {
    this.context.clearRect(0, 0, width, height);
  }

  draw (cx, cy, color, radius, coefficient) {
    this.context.save();

    const ticks = this.getTicks(parseInt(360 * coefficient), this.tickSize, radius, coefficient);

    ticks.forEach(tick => {
      this.drawTick(cx, cy, color, tick.x1, tick.y1, tick.x2, tick.y2);
    });

    this.context.restore();
  }

}
