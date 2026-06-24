#!/usr/bin/env python3
"""
Download wiki job sprites into assets/images/jobs/

Sources (in order):
  1. iRO Wiki job portraits (Category:Job_Images)
  2. Fandom RO_{Name}(SD).png SD sprites
  3. Divine Pride (via curl — SSL chain issues in some Python builds)

Usage:
  python tools/fetch-job-sprites.py
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WIKI_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, '..'))
DEST = os.path.join(WIKI_DIR, 'assets', 'images', 'jobs')
MIN_BYTES = 2500

UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) PRO-Ragnarok-Wiki/1.0'

# job_id -> iRO Wiki File: name (without "File:" prefix)
IRO_FILES = {
	0: 'Novice.png',
	1: 'Swordman.png',
	2: 'Mage.png',
	3: 'Archer.png',
	4: 'Acolyte.png',
	5: 'Merchant.png',
	6: 'Thief.png',
	7: 'Knight.png',
	8: 'Priest.png',
	9: 'Wizard.png',
	10: 'Blacksmith.png',
	11: 'Hunter.png',
	12: 'Assassin.png',
	14: 'Crusader.png',
	15: 'Monk.png',
	16: 'Sage.png',
	17: 'Rogue.png',
	18: 'Alchemist.png',
	19: 'Bard.png',
	20: 'Dancer.png',
	23: 'Super Novice.png',
	24: 'Gunslinger.png',
	25: 'Ninja.png',
	4008: 'Lord Knight.png',
	4009: 'High Priest.png',
	4010: 'High Wizard.png',
	4011: 'Mastersmith.png',
	4012: 'Sniper.png',
	4013: 'Assassin Cross.png',
	4014: 'Champion.png',
	4015: 'Paladin.png',
	4016: 'Scholar.png',
	4017: 'Stalker.png',
	4019: 'Biochemist.png',
	4020: 'Minstrel.png',
	4021: 'Gypsy.png',
	4046: 'TaeKwon Kid.png',
	4047: 'TaeKwon Master.png',
	4049: 'Soul Linker.png',
	4054: 'Rune Knight.png',
}

# job_id -> Fandom File: RO_{Name}(SD).png
FANDOM_SD = {
	0: 'RO_Novice(SD).png',
	1: 'RO_Swordman(SD).png',
	2: 'RO_Mage(SD).png',
	3: 'RO_Archer(SD).png',
	4: 'RO_Acolyte(SD).png',
	5: 'RO_Merchant(SD).png',
	6: 'RO_Thief(SD).png',
	7: 'RO_Knight(SD).png',
	8: 'RO_Priest(SD).png',
	9: 'RO_Wizard(SD).png',
	10: 'RO_Blacksmith(SD).png',
	11: 'RO_Hunter(SD).png',
	12: 'RO_Assassin(SD).png',
	14: 'RO_Crusader(SD).png',
	15: 'RO_Monk(SD).png',
	16: 'RO_Sage(SD).png',
	17: 'RO_Rogue(SD).png',
	18: 'RO_Alchemist(SD).png',
	19: 'RO_Bard(SD).png',
	20: 'RO_Dancer(SD).png',
	23: 'RO_Super_Novice(SD).png',
	24: 'RO_Gunslinger(SD).png',
	25: 'RO_Ninja(SD).png',
	4008: 'RO_Lord_Knight(SD).png',
	4009: 'RO_High_Priest(SD).png',
	4010: 'RO_High_Wizard(SD).png',
	4011: 'RO_Whitesmith(SD).png',
	4012: 'RO_Sniper(SD).png',
	4013: 'RO_Assassin_Cross(SD).png',
	4014: 'RO_Champion(SD).png',
	4015: 'RO_Paladin(SD).png',
	4016: 'RO_Professor(SD).png',
	4017: 'RO_Stalker(SD).png',
	4019: 'RO_Creator(SD).png',
	4020: 'RO_Clown(SD).png',
	4021: 'RO_Gypsy(SD).png',
	4046: 'RO_Taekwon_Kid(SD).png',
	4047: 'RO_Star_Gladiator(SD).png',
	4049: 'RO_Soul_Linker(SD).png',
	4054: 'RO_Rune_Knight(SD).png',
	4055: 'RO_Warlock(SD).png',
	4056: 'RO_Ranger(SD).png',
	4057: 'RO_Arch_Bishop(SD).png',
	4058: 'RO_Mechanic(SD).png',
	4059: 'RO_Guillotine_Cross(SD).png',
	4066: 'RO_Royal_Guard(SD).png',
	4067: 'RO_Sorcerer(SD).png',
	4068: 'RO_Minstrel(SD).png',
	4069: 'RO_Wanderer(SD).png',
	4070: 'RO_Sura(SD).png',
	4071: 'RO_Genetic(SD).png',
	4072: 'RO_Shadow_Chaser(SD).png',
	4211: 'RO_Kagerou(SD).png',
	4212: 'RO_Oboro(SD).png',
	4215: 'RO_Rebellion(SD).png',
	4218: 'RO_Summoner(SD).png',
	4239: 'RO_Star_Emperor(SD).png',
	4240: 'RO_Soul_Reaper(SD).png',
	4252: 'RO_Dragon_Knight(SD).png',
	4253: 'RO_Meister(SD).png',
	4254: 'RO_Shadow_Cross(SD).png',
	4255: 'RO_Arch_Mage(SD).png',
	4256: 'RO_Cardinal(SD).png',
	4257: 'RO_Wind_Hawk(SD).png',
	4258: 'RO_Imperial_Guard(SD).png',
	4259: 'RO_Biolo(SD).png',
	4260: 'RO_Abyss_Chaser(SD).png',
	4261: 'RO_Elemental_Master(SD).png',
	4262: 'RO_Inquisitor(SD).png',
	4263: 'RO_Troubadour(SD).png',
	4264: 'RO_Trouvere(SD).png',
	4305: 'RO_Night_Watch(SD).png',
	4306: 'RO_Hyper_Novice(SD).png',
	4307: 'RO_Spirit_Handler(SD).png',
	4351: 'RO_Druid(SD).png',
	4353: 'RO_Karnos(SD).png',
	4355: 'RO_Alitea(SD).png',
}

# High-quality Fandom SD sprites (webp via static.wikia — works when API is filtered).
WIKIA_DIRECT = {
	0: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/6/6a/RO_Novice%28SD%29.png/revision/latest',
	1: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/4/4e/RO_Swordman%28SD%29.png/revision/latest',
	2: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/8/8c/RO_Mage%28SD%29.png/revision/latest',
	3: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/2/2a/RO_Archer%28SD%29.png/revision/latest',
	4: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/0/0f/RO_Acolyte%28SD%29.png/revision/latest',
	5: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/9/9a/RO_Merchant%28SD%29.png/revision/latest',
	6: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/3/3e/RO_Thief%28SD%29.png/revision/latest',
	7: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/a/ab/RO_Knight%28SD%29.png/revision/latest',
	8: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/5/5b/RO_Priest%28SD%29.png/revision/latest',
	9: 'https://static.wikia.nocookie.net/ragnarok_gamepedia_en/images/5/5f/RO_Wizard%28SD%29.png/revision/latest',
}

# When no portrait exists online, reuse the previous tier in the same job path.
FALLBACK_IDS = {
	4055: 4010, 4056: 4012, 4057: 4009, 4058: 4011, 4059: 4013,
	4066: 4015, 4067: 4016, 4068: 4020, 4069: 4021, 4070: 4014, 4071: 4019, 4072: 4017,
	4211: 25, 4212: 25, 4215: 24, 4239: 4047, 4240: 4049,
	4252: 4054, 4253: 4058, 4254: 4059, 4255: 4055, 4256: 4057,
	4257: 4056, 4258: 4066, 4259: 4071, 4260: 4072, 4261: 4067, 4262: 4070,
	4263: 4068, 4264: 4069, 4305: 4215, 4306: 23, 4307: 4218,
	4353: 4351, 4355: 4353,
}

JOB_IDS = [
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 23, 24, 25,
	4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4019, 4020, 4021,
	4046, 4047, 4049, 4054, 4055, 4056, 4057, 4058, 4059, 4066, 4067, 4068, 4069, 4070, 4071, 4072,
	4211, 4212, 4215, 4218, 4239, 4240, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4264,
	4305, 4306, 4307, 4351, 4353, 4355,
]

_iro_url_cache: dict[str, str] = {}


def is_valid_image(data: bytes) -> bool:
	if len(data) < 400:
		return False
	if data.startswith(b'<!DOCTYPE') or data.startswith(b'<html'):
		return False
	if b'CPakEx' in data:
		return False
	magic = (
		b'\x89PNG\r\n\x1a\n',
		b'GIF87a', b'GIF89a',
		b'\xff\xd8\xff',
		b'RIFF',
	)
	return any(data.startswith(m) for m in magic)


def http_get(url: str, referer: str | None = None) -> bytes | None:
	headers = {'User-Agent': UA}
	if referer:
		headers['Referer'] = referer
	req = urllib.request.Request(url, headers=headers)
	try:
		with urllib.request.urlopen(req, timeout=20) as resp:
			return resp.read()
	except (urllib.error.URLError, OSError):
		return None


def curl_get(url: str, referer: str | None = None) -> bytes | None:
	cmd = ['curl.exe', '-sL', '--max-time', '20']
	if referer:
		cmd.extend(['-H', f'Referer: {referer}'])
	cmd.extend(['-H', f'User-Agent: {UA}', '-k', url])
	try:
		result = subprocess.run(cmd, capture_output=True, check=False)
	except OSError:
		return None
	if result.returncode != 0 or not result.stdout:
		return None
	return result.stdout


def fetch_url(url: str, referer: str | None = None) -> bytes | None:
	data = http_get(url, referer)
	if data is not None and is_valid_image(data):
		return data
	data = curl_get(url, referer)
	if data is not None and is_valid_image(data):
		return data
	return None


def iro_file_url(filename: str) -> str | None:
	if filename in _iro_url_cache:
		return _iro_url_cache[filename]
	title = 'File:' + filename
	api = 'https://irowiki.org/w/api.php?' + urllib.parse.urlencode({
		'action': 'query',
		'titles': title,
		'prop': 'imageinfo',
		'iiprop': 'url',
		'format': 'json',
	})
	raw = http_get(api)
	if raw is None:
		return None
	try:
		payload = json.loads(raw.decode('utf-8'))
		pages = payload.get('query', {}).get('pages', {})
		for page in pages.values():
			info = page.get('imageinfo')
			if info:
				url = info[0].get('url')
				if url:
					_iro_url_cache[filename] = url
					return url
	except (json.JSONDecodeError, KeyError, IndexError):
		pass
	return None


def fandom_file_url(filename: str) -> str | None:
	title = 'File:' + filename
	api = 'https://ragnarok.fandom.com/api.php?' + urllib.parse.urlencode({
		'action': 'query',
		'titles': title,
		'prop': 'imageinfo',
		'iiprop': 'url',
		'format': 'json',
	})
	raw = curl_get(api)
	if raw is None:
		return None
	try:
		payload = json.loads(raw.decode('utf-8'))
		pages = payload.get('query', {}).get('pages', {})
		for page in pages.values():
			if 'missing' in page:
				continue
			info = page.get('imageinfo')
			if info:
				return info[0].get('url')
	except (json.JSONDecodeError, KeyError, IndexError):
		pass
	return None


def to_png_bytes(data: bytes) -> bytes | None:
	if data.startswith(b'\x89PNG'):
		return data
	if data.startswith(b'GIF'):
		try:
			from PIL import Image
			import io
			img = Image.open(io.BytesIO(data)).convert('RGBA')
			out = io.BytesIO()
			img.save(out, format='PNG')
			return out.getvalue()
		except Exception:
			return data
	if data.startswith(b'RIFF') and b'WEBP' in data[:16]:
		try:
			from PIL import Image
			import io
			img = Image.open(io.BytesIO(data)).convert('RGBA')
			out = io.BytesIO()
			img.save(out, format='PNG')
			return out.getvalue()
		except Exception:
			return None
	if data.startswith(b'\xff\xd8\xff'):
		try:
			from PIL import Image
			import io
			img = Image.open(io.BytesIO(data)).convert('RGBA')
			out = io.BytesIO()
			img.save(out, format='PNG')
			return out.getvalue()
		except Exception:
			return None
	return data if is_valid_image(data) else None


def existing_ok(job_id: int) -> bool:
	path = os.path.join(DEST, f'{job_id}.png')
	return os.path.isfile(path) and os.path.getsize(path) >= MIN_BYTES


def save_png(job_id: int, data: bytes) -> bool:
	png = to_png_bytes(data)
	if png is None or len(png) < 400:
		return False
	os.makedirs(DEST, exist_ok=True)
	path = os.path.join(DEST, f'{job_id}.png')
	with open(path, 'wb') as fh:
		fh.write(png)
	return os.path.getsize(path) >= 400


def generate_placeholder(job_id: int, label: str = '#') -> bool:
	try:
		from PIL import Image, ImageDraw, ImageFont
	except ImportError:
		return False
	size = 72
	img = Image.new('RGBA', (size, size), (28, 37, 48, 255))
	draw = ImageDraw.Draw(img)
	draw.rectangle((1, 1, size - 2, size - 2), outline=(154, 123, 26, 255))
	draw.rectangle((2, 2, size - 3, size - 3), outline=(201, 162, 39, 255))
	letter = (label or '#')[:1]
	try:
		font = ImageFont.truetype('segoeui.ttf', 28)
	except OSError:
		font = ImageFont.load_default()
	bbox = draw.textbbox((0, 0), letter, font=font)
	tx = (size - (bbox[2] - bbox[0])) // 2
	ty = (size - (bbox[3] - bbox[1])) // 2 - 4
	draw.text((tx, ty), letter, fill=(240, 230, 210, 255), font=font)
	draw.text((4, size - 14), str(job_id), fill=(201, 162, 39, 255))
	path = os.path.join(DEST, f'{job_id}.png')
	img.save(path, format='PNG')
	return os.path.getsize(path) >= 400


def copy_fallback(job_id: int) -> bool:
	fallback = FALLBACK_IDS.get(job_id)
	if fallback is None:
		return False
	src = os.path.join(DEST, f'{fallback}.png')
	dst = os.path.join(DEST, f'{job_id}.png')
	if not os.path.isfile(src) or os.path.getsize(src) < 400:
		return False
	shutil.copy2(src, dst)
	return os.path.getsize(dst) >= 400


def download_job(job_id: int) -> tuple[str, str]:
	if existing_ok(job_id):
		return 'skip', 'already cached'

	if job_id in WIKIA_DIRECT:
		data = curl_get(WIKIA_DIRECT[job_id], 'https://ragnarok.fandom.com/')
		if data and len(data) > 2000 and save_png(job_id, data):
			return 'ok', 'wikia'

	if job_id in IRO_FILES:
		url = iro_file_url(IRO_FILES[job_id])
		if url:
			data = fetch_url(url, 'https://irowiki.org/')
			if data and save_png(job_id, data):
				return 'ok', 'irowiki'

	for base in (
		f'https://static.divine-pride.net/images/jobs/png/{job_id}.png',
		f'https://www.divine-pride.net/images/jobs/png/{job_id}.png',
	):
		data = curl_get(base, 'https://www.divine-pride.net/')
		if data and not data.startswith(b'<!DOCTYPE') and save_png(job_id, data):
			return 'ok', 'divine-pride'

	if job_id in FANDOM_SD:
		url = fandom_file_url(FANDOM_SD[job_id])
		if url:
			data = curl_get(url, 'https://ragnarok.fandom.com/')
			if data and len(data) > 2000 and save_png(job_id, data):
				return 'ok', 'fandom'

	if copy_fallback(job_id):
		return 'ok', f"fallback:{FALLBACK_IDS[job_id]}"

	if generate_placeholder(job_id, 'J'):
		return 'gen', 'placeholder'

	return 'fail', 'no source'


def main() -> int:
	os.makedirs(DEST, exist_ok=True)
	ok = skip = fail = 0
	print(f'Downloading {len(JOB_IDS)} job sprites -> {DEST}\n')

	for job_id in JOB_IDS:
		status, source = download_job(job_id)
		if status == 'skip':
			print(f'[skip] {job_id}')
			skip += 1
		elif status == 'ok':
			size = os.path.getsize(os.path.join(DEST, f'{job_id}.png'))
			print(f'[ok]   {job_id} ({source}, {size} bytes)')
			ok += 1
		elif status == 'gen':
			size = os.path.getsize(os.path.join(DEST, f'{job_id}.png'))
			print(f'[gen]  {job_id} ({source}, {size} bytes)')
			ok += 1
		else:
			print(f'[fail] {job_id}')
			fail += 1
		time.sleep(0.12)

	print(f'\nDone. downloaded={ok} skipped={skip} failed={fail}')
	return 1 if fail else 0


if __name__ == '__main__':
	sys.exit(main())
