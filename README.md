# Digital Forensics Readiness Research

A defensive research repository for assessing whether an organization can preserve, collect, and use digital evidence effectively.

## Research areas

- Log-source availability and retention
- Time synchronization
- Endpoint, identity, network, and cloud evidence coverage
- Chain-of-custody procedures
- Collection authority and escalation paths
- Evidence storage and access controls
- Incident documentation and legal readiness

## Main tool

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Digital_Forensics_Readiness_Research.ps1 -InputCsv .\research\evidence-sources.csv
```

## Required CSV columns

`SourceName`, `Category`, `Owner`, `Enabled`, `RetentionDays`, `TimeSynchronized`, `CollectionProcedure`, `AccessControlled`, `Notes`

## Safety

Assessment and documentation only. No evidence sources, retention settings, or systems are changed.
