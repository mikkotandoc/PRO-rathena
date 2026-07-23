const fs = require('fs');

const path = require('path');



const ROOT = path.join(__dirname, '..');

const ENTRY = path.join(__dirname, 'data', 'itemmall_mapcache_entry.bin');

const DEFAULT_CACHE = path.join(ROOT, 'db', 're', 'map_cache.dat');

const IMPORT_CACHE = path.join(ROOT, 'db', 'import', 'map_cache.dat');

const MAP_NAME = 'itemmall';



function parseCache(data) {

	const mapCount = data.readUInt16LE(4);

	const maps = [];

	let pos = 8;

	for (let i = 0; i < mapCount; i++) {

		const name = data.slice(pos, pos + 12).toString('ascii').replace(/\0.*/, '');

		const xs = data.readInt16LE(pos + 12);

		const ys = data.readInt16LE(pos + 14);

		const len = data.readUInt32LE(pos + 16);

		const payload = data.slice(pos + 20, pos + 20 + len);

		maps.push({ name, xs, ys, payload });

		pos += 20 + len;

	}

	return maps;

}



function buildCache(maps) {

	const chunks = [];

	for (const entry of maps.sort((a, b) => a.name.localeCompare(b.name))) {

		const name = Buffer.alloc(12, 0);

		name.write(entry.name, 0, 'ascii');

		const header = Buffer.alloc(20);

		name.copy(header, 0);

		header.writeInt16LE(entry.xs, 12);

		header.writeInt16LE(entry.ys, 14);

		header.writeUInt32LE(entry.payload.length, 16);

		chunks.push(header, entry.payload);

	}

	const body = Buffer.concat(chunks);

	const out = Buffer.alloc(8 + body.length);

	out.writeUInt32LE(8 + body.length, 0);

	out.writeUInt16LE(maps.length, 4);

	body.copy(out, 8);

	return out;

}



function loadEntry() {

	if (!fs.existsSync(ENTRY)) {

		console.error('Missing entry blob:', ENTRY);

		process.exit(1);

	}

	const raw = fs.readFileSync(ENTRY);

	const name = raw.slice(0, 12).toString('ascii').replace(/\0.*/, '');

	const xs = raw.readInt16LE(12);

	const ys = raw.readInt16LE(14);

	const len = raw.readUInt32LE(16);

	const payload = raw.slice(20, 20 + len);

	return { name, xs, ys, payload };

}



function patchCache(dst) {

	if (!fs.existsSync(dst)) {

		console.error('Missing map cache:', dst);

		process.exit(1);

	}

	const entry = loadEntry();

	const maps = parseCache(fs.readFileSync(dst)).filter((m) => m.name !== MAP_NAME);

	maps.push(entry);

	fs.writeFileSync(dst, buildCache(maps));

	console.log(`Patched ${entry.name} (${entry.xs}x${entry.ys}) in ${dst}`);

}



const dst = fs.existsSync(IMPORT_CACHE) ? IMPORT_CACHE : DEFAULT_CACHE;

patchCache(dst);

