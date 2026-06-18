// Sync macro patrol farming maps from db/re/map_drops.yml (Play_RO_Gold_Coin_ global drops).
// Usage: node tools/sync_macro_patrol_maps.js

const fs = require('fs');
const path = require('path');

const yamlPath = path.join(__dirname, '..', 'db', 're', 'map_drops.yml');
const text = fs.readFileSync(yamlPath, 'utf8');

const maps = [];
let current = null;

for (const line of text.split(/\r?\n/)) {
	const mapMatch = line.match(/^\s*- Map:\s*(.+)\s*$/);
	if (mapMatch) {
		current = mapMatch[1].trim();
		continue;
	}

	if (current && /Item:\s*Play_RO_Gold_Coin_/.test(line)) {
		maps.push(current);
	}
}

const unique = [...new Set(maps)].sort();
console.log(`Found ${unique.length} farming maps with Play_RO_Gold_Coin_ drops:\n`);
for (const map of unique) {
	console.log(`\t${map}`);
}

console.log('\nsetarray .farm_maps$,');
for (let i = 0; i < unique.length; i++) {
	const suffix = i < unique.length - 1 ? ',' : ';';
	console.log(`\t"${unique[i]}"${suffix}`);
}
