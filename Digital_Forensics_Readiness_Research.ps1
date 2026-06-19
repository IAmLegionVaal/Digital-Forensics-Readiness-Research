#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Digital_Forensics_Readiness_Research'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
if(-not(Test-Path $InputCsv)){Write-Error 'Input CSV not found.';return}
$rows=Import-Csv $InputCsv|ForEach-Object{
 $enabled=$_.Enabled -match 'Yes|True'
 $synced=$_.TimeSynchronized -match 'Yes|True'
 $procedure=-not [string]::IsNullOrWhiteSpace($_.CollectionProcedure)
 $controlled=$_.AccessControlled -match 'Yes|True'
 $retention=0;[void][int]::TryParse($_.RetentionDays,[ref]$retention)
 $score=0;if($enabled){$score+=25};if($synced){$score+=20};if($procedure){$score+=25};if($controlled){$score+=20};if($retention -ge 30){$score+=10}
 [PSCustomObject]@{SourceName=$_.SourceName;Category=$_.Category;Owner=$_.Owner;Enabled=$enabled;RetentionDays=$retention;TimeSynchronized=$synced;CollectionProcedure=$_.CollectionProcedure;AccessControlled=$controlled;ReadinessScore=$score;ReadinessBand=$(if($score -ge 80){'Strong'}elseif($score -ge 50){'Developing'}else{'Weak'});Notes=$_.Notes}
}
$byCategory=$rows|Group-Object Category|ForEach-Object{[PSCustomObject]@{Category=$_.Name;Sources=$_.Count;AverageScore=[math]::Round((($_.Group.ReadinessScore|Measure-Object -Average).Average),1)}}
$gaps=$rows|Where-Object{$_.ReadinessScore -lt 80}|Select-Object SourceName,Category,Owner,Enabled,RetentionDays,TimeSynchronized,AccessControlled,ReadinessScore,ReadinessBand
$summary=[PSCustomObject]@{Sources=@($rows).Count;Strong=@($rows|Where-Object ReadinessBand -eq 'Strong').Count;Developing=@($rows|Where-Object ReadinessBand -eq 'Developing').Count;Weak=@($rows|Where-Object ReadinessBand -eq 'Weak').Count;AverageScore=[math]::Round((($rows.ReadinessScore|Measure-Object -Average).Average),1);Generated=Get-Date}
$rows|Export-Csv (Join-Path $OutputPath "evidence_sources_$stamp.csv") -NoTypeInformation -Encoding UTF8
$byCategory|Export-Csv (Join-Path $OutputPath "category_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
$gaps|Export-Csv (Join-Path $OutputPath "readiness_gaps_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Summary=$summary;Sources=$rows;CategorySummary=$byCategory;Gaps=$gaps}|ConvertTo-Json -Depth 8|Set-Content (Join-Path $OutputPath "forensics_readiness_$stamp.json") -Encoding UTF8
$html="<h1>Digital Forensics Readiness Research</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Category Summary</h2>$($byCategory|ConvertTo-Html -Fragment)<h2>Readiness Gaps</h2>$($gaps|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Digital Forensics Readiness Research'|Set-Content (Join-Path $OutputPath "forensics_readiness_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
