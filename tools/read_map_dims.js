const fs = require('fs');
const path = process.argv[2] || 'db/re/map_cache.dat';
const data = fs.readFileSync(path);
let pos = 8;
const mapCount = data.readUInt16LE(4);
const targets = new Set(['1@20cn1', '1@20cn2']);
for (let i = 0; i < mapCount; i++) {
	const name = data.slice(pos, pos + 12).toString('ascii').replace(/\0.*/, '');
	const xs = data.readInt16LE(pos + 12);
	const ys = data.readInt16LE(pos + 14);
	const len = data.readUInt32LE(pos + 16);
	if (targets.has(name)) {
		console.log(`${name}: ${xs}x${ys}`);
	}
	pos += 12 + 8 + len;
}
