// Generates 220x90 24-bit BMP captcha images for rAthena macro detector.
// Usage: node tools/gen_captcha_bmp.js

const fs = require('fs');
const path = require('path');

const WIDTH = 220;
const HEIGHT = 90;
const CAPTCHA_BMP_SIZE = 2 + 52 + (3 * WIDTH * HEIGHT);

const FONT = {
	A: ['01110','10001','10001','11111','10001','10001','10001'],
	B: ['11110','10001','10001','11110','10001','10001','11110'],
	C: ['01111','10000','10000','10000','10000','10000','01111'],
	D: ['11110','10001','10001','10001','10001','10001','11110'],
	E: ['11111','10000','10000','11110','10000','10000','11111'],
	F: ['11111','10000','10000','11110','10000','10000','10000'],
	G: ['01111','10000','10000','10011','10001','10001','01111'],
	H: ['10001','10001','10001','11111','10001','10001','10001'],
	J: ['00111','00010','00010','00010','00010','10010','01100'],
	K: ['10001','10010','10100','11000','10100','10010','10001'],
	L: ['10000','10000','10000','10000','10000','10000','11111'],
	M: ['10001','11011','10101','10001','10001','10001','10001'],
	N: ['10001','11001','10101','10011','10001','10001','10001'],
	P: ['11110','10001','10001','11110','10000','10000','10000'],
	R: ['11110','10001','10001','11110','10100','10010','10001'],
	S: ['01111','10000','10000','01110','00001','00001','11110'],
	T: ['11111','00100','00100','00100','00100','00100','00100'],
	U: ['10001','10001','10001','10001','10001','10001','01110'],
	V: ['10001','10001','10001','10001','10001','01010','00100'],
	W: ['10001','10001','10001','10001','10101','11011','10001'],
	X: ['10001','10001','01010','00100','01010','10001','10001'],
	Y: ['10001','10001','01010','00100','00100','00100','00100'],
	Z: ['11111','00001','00010','00100','01000','10000','11111'],
	2: ['01110','10001','00001','00010','00100','01000','11111'],
	3: ['11110','00001','00001','01110','00001','00001','11110'],
	4: ['00010','00110','01010','10010','11111','00010','00010'],
	5: ['11111','10000','10000','11110','00001','00001','11110'],
	6: ['01111','10000','10000','11111','10001','10001','01110'],
	7: ['11111','00001','00010','00100','01000','01000','01000'],
	8: ['01110','10001','10001','01110','10001','10001','01110'],
	9: ['01110','10001','10001','01111','00001','00001','01110'],
};

const CAPTCHAS = [
	[1, 'ALPHA'],
	[2, 'BRAVE'],
	[3, 'CLOUD'],
	[4, 'DELTA'],
	[5, 'EAGLE'],
	[6, 'FLAME'],
	[7, 'GUARD'],
	[8, 'HONOR'],
	[9, 'JUDGE'],
	[10, 'KNIFE'],
];

function setPx(buf, x, y, b, g, r) {
	if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return;
	const idx = ((HEIGHT - 1 - y) * WIDTH + x) * 3;
	buf[idx] = b;
	buf[idx + 1] = g;
	buf[idx + 2] = r;
}

function drawText(buf, text, scale = 4) {
	const upper = text.toUpperCase();
	const charW = 5 * scale + scale;
	const totalW = upper.length * charW - scale;
	const startX = Math.max(2, Math.floor((WIDTH - totalW) / 2));
	const startY = Math.floor((HEIGHT - 7 * scale) / 2);

	for (let ci = 0; ci < upper.length; ci++) {
		const glyph = FONT[upper[ci]];
		if (!glyph) continue;
		const ox = startX + ci * charW;
		for (let row = 0; row < glyph.length; row++) {
			for (let col = 0; col < glyph[row].length; col++) {
				if (glyph[row][col] !== '1') continue;
				for (let dy = 0; dy < scale; dy++) {
					for (let dx = 0; dx < scale; dx++) {
						setPx(buf, ox + col * scale + dx, startY + row * scale + dy, 20, 40, 180);
					}
				}
			}
		}
	}
}

function makeBmp(text) {
	const pixels = Buffer.alloc(WIDTH * HEIGHT * 3, 235);
	for (let y = 0; y < HEIGHT; y++) {
		for (let x = 0; x < WIDTH; x++) {
			const v = 230 + Math.floor(Math.random() * 31) - 15;
			setPx(pixels, x, y, v, v, v);
		}
	}
	for (let i = 0; i < 40; i++) {
		let x1 = Math.floor(Math.random() * WIDTH);
		let y1 = Math.floor(Math.random() * HEIGHT);
		let x2 = Math.floor(Math.random() * WIDTH);
		let y2 = Math.floor(Math.random() * HEIGHT);
		const steps = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1), 1);
		for (let s = 0; s <= steps; s++) {
			const x = x1 + Math.floor(((x2 - x1) * s) / steps);
			const y = y1 + Math.floor(((y2 - y1) * s) / steps);
			setPx(pixels, x, y, 160, 160, 160);
		}
	}
	drawText(pixels, text);

	const fileHeader = Buffer.alloc(14);
	fileHeader.write('BM');
	fileHeader.writeUInt32LE(CAPTCHA_BMP_SIZE, 2);
	fileHeader.writeUInt32LE(0, 6);
	fileHeader.writeUInt32LE(54, 10);

	const infoHeader = Buffer.alloc(40);
	infoHeader.writeUInt32LE(40, 0);
	infoHeader.writeInt32LE(WIDTH, 4);
	infoHeader.writeInt32LE(HEIGHT, 8);
	infoHeader.writeUInt16LE(1, 12);
	infoHeader.writeUInt16LE(24, 14);
	infoHeader.writeUInt32LE(0, 16);
	infoHeader.writeUInt32LE(pixels.length, 20);
	infoHeader.writeInt32LE(2835, 24);
	infoHeader.writeInt32LE(2835, 28);
	infoHeader.writeUInt32LE(0, 32);
	infoHeader.writeUInt32LE(0, 36);

	const data = Buffer.concat([fileHeader, infoHeader, pixels]);
	if (data.length !== CAPTCHA_BMP_SIZE) {
		throw new Error(`Invalid BMP size ${data.length}, expected ${CAPTCHA_BMP_SIZE}`);
	}
	return data;
}

const outDir = path.join(__dirname, '..', 'db', 'import', 'captcha');
fs.mkdirSync(outDir, { recursive: true });

for (const [id, word] of CAPTCHAS) {
	const file = path.join(outDir, `captcha_${String(id).padStart(2, '0')}.bmp`);
	fs.writeFileSync(file, makeBmp(word));
	console.log(`Created ${file} (${word})`);
}

console.log('Done.');
