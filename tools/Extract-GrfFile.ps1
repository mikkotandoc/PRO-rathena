# Extract one file from a GRF archive (Master of Magic format, version 0x200).
param(
	[Parameter(Mandatory = $true)][string]$GrfPath,
	[Parameter(Mandatory = $true)][string]$InternalPath,
	[Parameter(Mandatory = $true)][string]$OutputPath,
	[switch]$ListOnly
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

function Un-ZlibBytes {
	param([byte[]]$Data)
	if ($Data.Length -lt 6) {
		throw 'Zlib payload too small'
	}
	# zlib wrapper: 2-byte header + deflate stream + 4-byte adler32
	$deflated = $Data[2..($Data.Length - 5)]
	$msIn = New-Object System.IO.MemoryStream(,$deflated)
	$msOut = New-Object System.IO.MemoryStream
	try {
		$ds = New-Object System.IO.Compression.DeflateStream(
			$msIn,
			[System.IO.Compression.CompressionMode]::Decompress
		)
		$ds.CopyTo($msOut)
		$ds.Dispose()
	}
	finally {
		$msIn.Dispose()
	}
	$out = $msOut.ToArray()
	$msOut.Dispose()
	return ,$out
}

function Get-GrfV2Entries {
	param([string]$Path)

	$fs = [System.IO.File]::OpenRead($Path)
	try {
		$hdr = New-Object byte[] 0x2E
		[void]$fs.Read($hdr, 0, 0x2E)
		$magic = [System.Text.Encoding]::ASCII.GetString($hdr, 0, 16).TrimEnd([char]0)
		if ($magic -ne 'Master of Magic') {
			throw "Unsupported GRF header: $magic"
		}

		$relOff = [BitConverter]::ToUInt32($hdr, 0x1E)
		$ver = [BitConverter]::ToUInt32($hdr, 0x2A) -shr 8
		if ($ver -ne 0x02) {
			throw "GRF version 0x$($ver.ToString('X2')) is not supported (need 0x02)"
		}

		$entryCount = [BitConverter]::ToUInt32($hdr, 0x26) - 7
		$fs.Seek(0x2E + $relOff, [System.IO.SeekOrigin]::Begin) | Out-Null

		$eh = New-Object byte[] 8
		[void]$fs.Read($eh, 0, 8)
		$rSize = [BitConverter]::ToUInt32($eh, 0)
		$eSize = [BitConverter]::ToUInt32($eh, 4)
		$rBuf = New-Object byte[] $rSize
		[void]$fs.Read($rBuf, 0, $rSize)
		$fileList = Un-ZlibBytes $rBuf
		if ($fileList.Length -ne $eSize) {
			Write-Warning "File list size mismatch: got $($fileList.Length), expected $eSize"
		}
	}
	finally {
		$fs.Dispose()
	}

	$enc949 = [System.Text.Encoding]::GetEncoding(949)
	$entries = New-Object System.Collections.Generic.List[object]
	$ofs = 0
	for ($i = 0; $i -lt $entryCount; $i++) {
		$nameEnd = $ofs
		while ($nameEnd -lt $fileList.Length -and $fileList[$nameEnd] -ne 0) {
			$nameEnd++
		}
		$nameLen = $nameEnd - $ofs
		$name = $enc949.GetString($fileList, $ofs, $nameLen)
		$ofs2 = $nameEnd + 1
		$packSize = [BitConverter]::ToUInt32($fileList, $ofs2 + 0)
		$sizeAligned = [BitConverter]::ToUInt32($fileList, $ofs2 + 4)
		$realSize = [BitConverter]::ToUInt32($fileList, $ofs2 + 8)
		$flags = $fileList[$ofs2 + 12]
		$srcPos = [BitConverter]::ToUInt32($fileList, $ofs2 + 13) + 0x2E
		if (($flags -band 0x01) -ne 0) {
			[void]$entries.Add([pscustomobject]@{
				Name = $name
				PackSize = $packSize
				SizeAligned = $sizeAligned
				RealSize = $realSize
				SrcPos = $srcPos
				Flags = $flags
			})
		}
		$ofs = $ofs2 + 17
	}
	return ,$entries
}

$entries = Get-GrfV2Entries -Path $GrfPath
Write-Host "GRF entries: $($entries.Count)"

if ($ListOnly) {
	$entries | ForEach-Object { $_.Name }
	return
}

$target = $InternalPath.Replace('/', '\').ToLowerInvariant()
$entry = $entries | Where-Object {
	$_.Name.Replace('/', '\').ToLowerInvariant() -eq $target
} | Select-Object -First 1

if (-not $entry) {
	$near = $entries | Where-Object { $_.Name -match 'ItemDBNameTbl|EnchantList' } | Select-Object -First 10
	if ($near) {
		Write-Host 'Similar paths:'
		$near | ForEach-Object { Write-Host "  $($_.Name)" }
	}
	throw "File not found in GRF: $InternalPath"
}

$fs = [System.IO.File]::OpenRead($GrfPath)
try {
	$fs.Seek($entry.SrcPos, [System.IO.SeekOrigin]::Begin) | Out-Null
	$data = New-Object byte[] $entry.PackSize
	[void]$fs.Read($data, 0, $entry.PackSize)
}
finally {
	$fs.Dispose()
}

if ($entry.PackSize -ne $entry.RealSize) {
	$outBytes = Un-ZlibBytes $data
	if ($outBytes.Length -ne $entry.RealSize) {
		Write-Warning "Decompressed size mismatch: got $($outBytes.Length), expected $($entry.RealSize)"
	}
}
else {
	$outBytes = $data
}

$dir = Split-Path $OutputPath -Parent
if ($dir -and -not (Test-Path $dir)) {
	New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
[System.IO.File]::WriteAllBytes($OutputPath, $outBytes)
Write-Host "Extracted: $($entry.Name) -> $OutputPath ($($outBytes.Length) bytes)"
