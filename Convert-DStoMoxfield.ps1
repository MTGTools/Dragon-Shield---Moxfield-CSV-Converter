Function Convert-DStoMoxfield{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$Filename
    )
    #Temp File Name
        $TempFileName="$((get-item $Filename).directory.FullName)"+"\MoxConvertTempFile.csv"
    #Remove Dragonshield Separator Value (First Line)
        $ImportedCSV=(Get-Content $Filename -encoding utf8  | Select-Object -Skip 2) 
    #Write out Tempfile for Reimport
        Set-Content -Path $TempFileName -value $ImportedCSV -encoding utf8
    #Fuck Dragonshield for using the same character as separator inside of quotes!!! 
        $SeparatorReplacer=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8
        foreach($SeparatorReplacerLine in $SeparatorReplacer){
            if($SeparatorReplacerLine -match '"'){
                #"Match : $String"
                $SplitSeparatorReplacerLine=$SeparatorReplacerLine.Split('"')
                #$SplitString[1]
                $SplitSeparatorReplacerLine[1]=$($SplitSeparatorReplacerLine[1] -replace ",",";")
                $RejoinString=$SplitSeparatorReplacerLine -join '"'
                $SplitSeparatorReplacerLine=$RejoinString -replace '"',''
                $ReconstructedLine=$SplitSeparatorReplacerLine -join ","
                $ReconstructedLine | Out-File $TempFileName -Append -encoding utf8
                #$ReconstructedLine 
            }
            else{
                $ReconstructedLine=$SeparatorReplacerLine
                $ReconstructedLine | Out-File $TempFileName -Append -encoding utf8
                #$ReconstructedLine 
            }
         }               
    #Convert Conditions from DragonShield to Moxfield
        $ConditionReplacer=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8
        foreach($ConditionReplaceLine in $ConditionReplacer){
            $ConditionReplaceLineSplit=$ConditionReplaceLine -split ","
            if($ConditionReplaceLineSplit[7] -eq "NearMint"){$ConditionReplaceLineSplit[7]="Near Mint"}
            if($ConditionReplaceLineSplit[7] -eq "Excellent"){$ConditionReplaceLineSplit[7]="Near Mint"}
            if($ConditionReplaceLineSplit[7] -eq "Good"){$ConditionReplaceLineSplit[7]="Good (Lightly Played)"}
            if($ConditionReplaceLineSplit[7] -eq "LightPlayed"){$ConditionReplaceLineSplit[7]="Played"}
            if($ConditionReplaceLineSplit[7] -eq "Played"){$ConditionReplaceLineSplit[7]="Heavily Played"}
            if($ConditionReplaceLineSplit[7] -eq "Poor"){$ConditionReplaceLineSplit[7]="Damaged"}
            $ReconstructedLine=$ConditionReplaceLineSplit -join ","
            $ReconstructedLine | Out-File $TempFileName -Append -encoding utf8
        }
    #Convert Foils from DragonShield to Moxfield
        $FoilReplacer=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8
        foreach($FoilReplacerLine in $FoilReplacer){
            $FoilReplacerLineSplit=$FoilReplacerLine -split ","
            if($FoilReplacerLineSplit[8] -eq "Foil"){
                $FoilReplacerLineSplit[8]="foil"
                #$FoilReplacerLineSplit[8]
            }
            if($FoilReplacerLineSplit[8] -eq "Normal"){
                #$FoilReplacerLineSplit[8]
                $FoilReplacerLineSplit[8]=$null
                #$FoilReplacerLineSplit[8]
            }
            #$FoilReplacerLineSplit[8]
            $ReconstructedLine=$FoilReplacerLineSplit -join ","
            $ReconstructedLine | Out-File $TempFileName -Append -encoding utf8
        }
     #Convert Date from DragonShield to Moxfield
        $DateReplacer=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8
        foreach($DateReplacerLine in $DateReplacer){
            $DateReplacerLineSplit=$DateReplacerLine -split ","
            $DateReplacerLineSplit[11]="$($DateReplacerLineSplit[11]) $(get-date -Format "hh:mm:ss.ffffff")"
            $ReconstructedLine=$DateReplacerLineSplit -join ","
            $ReconstructedLine | Out-File $TempFileName -Append -encoding utf8
        }
    #Convert Tokens from DragonShield to Moxfield
        $TokenReplacer=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8  
        foreach($TokenReplacerLine in $TokenReplacer){
            if($TokenReplacerLine -match  "Tokens"){
                #$TokenReplacerLine
                $TokenReplacerLineSplit=$TokenReplacerLine.Split(",")
                $TokenReplacerLinesSplitTokenSplit=$TokenReplacerLineSplit[3] -split " Token"
                $TokenNameDragonShield=$($TokenReplacerLineSplit[3])
                $TokenNameMox=$($TokenReplacerLinesSplitTokenSplit[0])
                #"$TokenNameDragonShield, $TokenNameMox"
                $ReplacedTokenReplacerLine=$TokenReplacerLine.Replace($TokenNameDragonShield,$TokenNameMox)
                #$ReplacedTokenReplacerLine
                $ReplacedTokenReplacerLine | Out-File $TempFileName -Append -encoding utf8
            }          
            else{
                $TokenReplacerLine | Out-File $TempFileName -Append -encoding utf8
                #$TokenReplacerLine
            }
        }
    #Add Quotes for Moxfield
        $QuotesAdder=Get-Content $TempFileName -encoding utf8
        Set-Content -Value $null -Path $TempFileName -encoding utf8  
        foreach($QuotesAdderLine in $QuotesAdder){
            $ReconstructedLine=$null 
            $QuotesAdderLineCommaSplit=$QuotesAdderLine -split ","
            $i=0
            foreach($SplitItem in $QuotesAdderLineCommaSplit){
                $QuotesAdderLineCommaSplit[$i]="`"$SplitItem`""
                $i++
            }
            $ReconstructedLine=$QuotesAdderLineCommaSplit -join ","
            $ReconstructedLine  | Out-File $TempFileName -Append -encoding utf8
            #$ReconstructedLine
        }
   #Write Out Moxfield File
        $OutputFileName="$((get-item $Filename).directory.FullName)"+"\$($Filename)_Moxified.csv"
        Set-Content -Value $null -Path $OutputFileName -encoding utf8  
        '"Count","Tradelist Count","Name","Edition","Condition","Language","Foil","Tags","Last Modified","Collector Number","Alter","Proxy","Purchase Price"' | Out-File $OutputFileName -Append -encoding utf8
        $ColumnSorter=Get-Content $TempFileName -encoding utf8
        foreach($ColumnSorterLine in $ColumnSorter){
            $ColumnSorterLineSplit=$ColumnSorterLine -split ','
            $Count=$ColumnSorterLineSplit[1]
            $TradelistCount=$ColumnSorterLineSplit[1]
            $Name=$ColumnSorterLineSplit[3]
            $Edition=$ColumnSorterLineSplit[4]
            $Condition=$ColumnSorterLineSplit[7]
            $Language=$ColumnSorterLineSplit[9]
            $Foil=$ColumnSorterLineSplit[8]
            $Tags="`"`""
            $LastModified=$ColumnSorterLineSplit[11]
            $CollectorNumber=$ColumnSorterLineSplit[6]
            $Alter="FALSE"
            $Proxy="FALSE"
            $PurchasePrice=$ColumnSorterLineSplit[10]
            #"$Name, $LastModified"
            $MoxifiedLine="$Count,$TradelistCount,$Name,$Edition,$Condition,$Language,$Foil,$Tags,$LastModified,$CollectorNumber,$Alter,$Proxy,$PurchasePrice"
            $MoxifiedLine | Out-File $OutputFileName -Append -encoding utf8
            #$MoxifiedLine
        }
    #Restore Commas in names for Moxfield
        $CommaRestorer=Get-Content $OutputFileName -encoding utf8
        Set-Content -Value $null -Path $OutputFileName -encoding utf8  
        foreach($CommaRestorerLine in  $CommaRestorer){
            $ReconstructedLine=$CommaRestorerLine.Replace(";",",")
            $ReconstructedLine  | Out-File $OutputFileName -Append -encoding utf8
            #$ReconstructedLine
        }
    #Reimport Tempfile
        Get-Content $OutputFileName
} 

Convert-DStoMoxfield -Filename .\AllScannedCards.csv
