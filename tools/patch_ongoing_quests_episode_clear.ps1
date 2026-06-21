# Patch OngoingQuests.lub episode clear chapter marker quest IDs
$ErrorActionPreference = 'Stop'
$LubPath = 'c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea\SystemEN\OngoingQuests.lub'

$ChapterQuests = [ordered]@{
	13210 = 'Other World Entry Related Quest'
	13211 = 'Adapting to New Environment'
	13212 = 'Conflict of Three Nations Alliance Investigation Team'
	13213 = 'Report to the Continent'
	13214 = "Dandelion's Request"
	13215 = 'Attitude Towards New Things'
	13216 = 'Gaining Trust from Cat Hand'
	13217 = 'Translator'
	13218 = 'Messenger'
	13219 = 'Continuing Research'
	13220 = 'Homesickness'
	13221 = 'To El Dicastes!'
	13222 = "Doha's Secret Order"
	13223 = "Fred's Request"
	14000 = 'Ep14.1 Bifrost'
	14001 = 'Ep14.2 Eclage'
	14002 = 'Ep14.3 Final Battle'
	15009 = 'Arunafeltz Excavation Team'
	15010 = 'Regenerating Memory'
	15011 = 'To Phantasmagorica!'
	15012 = 'Traces'
	15013 = 'Monthly Brigan'
	17040 = 'Ep17.1 New Operation Base'
	17041 = "Pax's Employment Journey"
	17042 = 'Regenscrhirm Recapture Operation'
	17043 = 'Old Memories'
	17044 = 'Sky Seen from the Well'
	17045 = 'Pure Mischievous Child'
	17046 = "Pax's Employment Journey 2"
	17100 = "Ep17.2 Mansion's Doghole"
	17101 = 'Straggler in the Sewer'
	17102 = 'Cannot Find Network'
	17103 = 'I Want to Know That'
	17104 = 'Pest Extermination Operation'
	17105 = 'Attending the Coronation'
	17106 = 'Water Garden'
	17107 = 'Be Quiet in the Library'
	17108 = 'Bathhouse, Strange Creature and Me'
	18150 = 'To the Church State'
	18151 = "Niren's Request"
	18152 = 'Children of Gray'
	18153 = "Oz's Maze and the Merchant"
	18154 = 'Daily Bread to Be Thankful For'
	18155 = 'Sacred Relic for Essence'
	18156 = 'Belated Migration'
	18157 = "I Can't Sleep"
	18158 = 'This Is Not That Place'
	18159 = 'Where Is My Home'
	18160 = 'There Are No Bad Beasts in the World'
	18161 = 'Gray Village Governor Candidate'
	18162 = 'Great Meeting in Gray Wolf Forest'
	18163 = "Wolf in Sheep's Clothing"
	18164 = 'Sacred Deception'
	19200 = 'Guest Who Came on the North Wind'
	19201 = 'Patrol with Awin'
	19202 = 'Encounter with Experiment Subject 210426'
	19203 = "Infiltration of Rgan's Dwelling"
	19204 = 'Finding Clues'
	19205 = 'Accumulating Suspicions'
	19206 = "Confused Snake's Nest"
	19207 = 'Finding Underground Hideout from the Surface'
	19208 = 'Airship Destruction Operation'
	19209 = 'Saint of Purification'
	19210 = 'Frozen Sea'
	20000 = 'Natives of the Ancient Ice Gorge'
	20001 = 'Era of Cold War and Espionage'
	20003 = 'More Expert Than Any Awin'
	20004 = "Kopo's Secret Base"
	20005 = "Infiltration of Rgans' Hideout"
	20006 = 'Where the End of the Maze Leads'
	20007 = 'Deep Ancient Sea'
	20008 = 'The Undying One'
}

$AddIds = @(
	13210..13223
	14000
	15009..15013
	19201..19210
)

$UpdateIds = $ChapterQuests.Keys | Where-Object { $_ -notin $AddIds } | Sort-Object

function Make-Block([int]$Qid, [string]$Title) {
	$escaped = $Title -replace '\\', '\\' -replace '"', '\"'
	return @"
	[$Qid] = {
		Title = "$escaped",
		IconName = "ico_ep.bmp",
		Description = {
			"$escaped"
		},
		Summary = "$escaped"
	},
"@
}

function Find-BlockSpan([string[]]$Lines, [int]$Qid) {
	$pattern = "^\s*\[$Qid\]\s*=\s*\{"
	$start = -1
	for ($i = 0; $i -lt $Lines.Count; $i++) {
		if ($Lines[$i] -match $pattern) { $start = $i; break }
	}
	if ($start -lt 0) { return $null }
	$depth = 0
	for ($j = $start; $j -lt $Lines.Count; $j++) {
		$depth += ([regex]::Matches($Lines[$j], '\{')).Count
		$depth -= ([regex]::Matches($Lines[$j], '\}')).Count
		if ($depth -eq 0 -and $j -gt $start) { return @{ Start = $start; End = $j } }
	}
	return $null
}

$text = [System.IO.File]::ReadAllText($LubPath)
$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]]($text -split "`r?`n", -1))
# Remove trailing empty from split if file ends with newline
if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') { $lines.RemoveAt($lines.Count - 1) }

foreach ($qid in $UpdateIds) {
	$span = Find-BlockSpan $lines $qid
	if (-not $span) { Write-Host "WARN: [$qid] not found for update"; continue }
	$newBlock = (Make-Block $qid $ChapterQuests[$qid]) -split "`n"
	$lines.RemoveRange($span.Start, $span.End - $span.Start + 1)
	for ($k = 0; $k -lt $newBlock.Count; $k++) {
		$lines.Insert($span.Start + $k, $newBlock[$k])
	}
	Write-Host "Updated [$qid]"
}

$insertAfter = @{
	13210 = 13205
	14000 = 14001
	15009 = 15008
	19201 = 19200
}

foreach ($qid in ($AddIds | Sort-Object)) {
	if ($qid -eq 14000) {
		$span = Find-BlockSpan $lines 14001
		if (-not $span) { throw "Cannot insert [14000], [14001] missing" }
		$insertAt = $span.Start
	} elseif ($insertAfter.ContainsKey($qid)) {
		$anchor = $insertAfter[$qid]
		$span = Find-BlockSpan $lines $anchor
		if (-not $span) { throw "Cannot insert [$qid], anchor [$anchor] missing" }
		$insertAt = $span.End + 1
	} else {
		$prev = $qid - 1
		$span = Find-BlockSpan $lines $prev
		if (-not $span) { throw "Cannot insert [$qid], prev [$prev] missing" }
		$insertAt = $span.End + 1
	}
	$newBlock = (Make-Block $qid $ChapterQuests[$qid]) -split "`n"
	for ($k = $newBlock.Count - 1; $k -ge 0; $k--) {
		$lines.Insert($insertAt, $newBlock[$k])
	}
	Write-Host "Inserted [$qid] at line $($insertAt + 1)"
}

$nl = if ($text -match "`r`n") { "`r`n" } else { "`n" }
[System.IO.File]::WriteAllText($LubPath, ($lines -join $nl) + $nl, [System.Text.UTF8Encoding]::new($false))
Write-Host "Done. Wrote $LubPath"
