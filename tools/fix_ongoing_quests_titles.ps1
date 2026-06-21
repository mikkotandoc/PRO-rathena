# Fix empty episode chapter marker titles in OngoingQuests.lub
$ErrorActionPreference = 'Stop'
$LubPath = 'c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea\SystemEN\OngoingQuests.lub'

$Pairs = @(
	'13210|Other World Entry Related Quest'
	'13211|Adapting to New Environment'
	'13212|Conflict of Three Nations Alliance Investigation Team'
	'13213|Report to the Continent'
	'13214|Dandelion''s Request'
	'13215|Attitude Towards New Things'
	'13216|Gaining Trust from Cat Hand'
	'13217|Translator'
	'13218|Messenger'
	'13219|Continuing Research'
	'13220|Homesickness'
	'13221|To El Dicastes!'
	'13222|Doha''s Secret Order'
	'13223|Fred''s Request'
	'14000|Ep14.1 Bifrost'
	'14001|Ep14.2 Eclage'
	'14002|Ep14.3 Final Battle'
	'15009|Arunafeltz Excavation Team'
	'15010|Regenerating Memory'
	'15011|To Phantasmagorica!'
	'15012|Traces'
	'15013|Monthly Brigan'
	'17040|Ep17.1 New Operation Base'
	'17041|Pax''s Employment Journey'
	'17042|Regenscrhirm Recapture Operation'
	'17043|Old Memories'
	'17044|Sky Seen from the Well'
	'17045|Pure Mischievous Child'
	'17046|Pax''s Employment Journey 2'
	'17100|Ep17.2 Mansion''s Doghole'
	'17101|Straggler in the Sewer'
	'17102|Cannot Find Network'
	'17103|I Want to Know That'
	'17104|Pest Extermination Operation'
	'17105|Attending the Coronation'
	'17106|Water Garden'
	'17107|Be Quiet in the Library'
	'17108|Bathhouse, Strange Creature and Me'
	'18150|To the Church State'
	'18151|Niren''s Request'
	'18152|Children of Gray'
	'18153|Oz''s Maze and the Merchant'
	'18154|Daily Bread to Be Thankful For'
	'18155|Sacred Relic for Essence'
	'18156|Belated Migration'
	'18157|I Can''t Sleep'
	'18158|This Is Not That Place'
	'18159|Where Is My Home'
	'18160|There Are No Bad Beasts in the World'
	'18161|Gray Village Governor Candidate'
	'18162|Great Meeting in Gray Wolf Forest'
	'18163|Wolf in Sheep''s Clothing'
	'18164|Sacred Deception'
	'19200|Guest Who Came on the North Wind'
	'19201|Patrol with Awin'
	'19202|Encounter with Experiment Subject 210426'
	'19203|Infiltration of Rgan''s Dwelling'
	'19204|Finding Clues'
	'19205|Accumulating Suspicions'
	'19206|Confused Snake''s Nest'
	'19207|Finding Underground Hideout from the Surface'
	'19208|Airship Destruction Operation'
	'19209|Saint of Purification'
	'19210|Frozen Sea'
	'20000|Natives of the Ancient Ice Gorge'
	'20001|Era of Cold War and Espionage'
	'20003|More Expert Than Any Awin'
	'20004|Kopo''s Secret Base'
	'20005|Infiltration of Rgans'' Hideout'
	'20006|Where the End of the Maze Leads'
	'20007|Deep Ancient Sea'
	'20008|The Undying One'
)

function Make-EmptyBlock([int]$Id) {
	return "[${Id}] = {`r`n`t`tTitle = `"`",`r`n`t`tIconName = `"ico_ep.bmp`",`r`n`t`tDescription = {`r`n`t`t`t`"`"`r`n`t`t},`r`n`t`tSummary = `"`"`r`n`t},"
}

function Make-FilledBlock([int]$Id, [string]$Title) {
	$escaped = $Title -replace '\\', '\\' -replace '"', '\"'
	return "[${Id}] = {`r`n`t`tTitle = `"$escaped`",`r`n`t`tIconName = `"ico_ep.bmp`",`r`n`t`tDescription = {`r`n`t`t`t`"$escaped`"`r`n`t`t},`r`n`t`tSummary = `"$escaped`"`r`n`t},"
}

$text = [System.IO.File]::ReadAllText($LubPath)
$fixed = 0

foreach ($pair in $Pairs) {
	$parts = $pair -split '\|', 2
	$id = [int]$parts[0]
	$title = $parts[1]
	$old = Make-EmptyBlock $id
	$new = Make-FilledBlock $id $title

	if ($text.Contains($old)) {
		$text = $text.Replace($old, $new)
		$fixed++
		Write-Host "Fixed [$id]"
	} else {
		Write-Warning "Pattern not found for [$id]"
	}
}

if ($fixed -ne $Pairs.Count) {
	throw "Only fixed $fixed of $($Pairs.Count) entries"
}

[System.IO.File]::WriteAllText($LubPath, $text, [System.Text.UTF8Encoding]::new($false))
Write-Host "Done. Fixed $fixed entries in $LubPath"
