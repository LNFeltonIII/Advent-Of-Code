#I'll solve this by doing a small reproduction of objects obtained from the commandlets Get-Item and Get-ChildItem. I will build objects which will have the following properties for each line item which indicates command output:
<#
FullName          : C:\Users\Neal\Documents\PowerShell\Scripts\AdventOfCode\2022\day7_input.txt
ParentPath        : C:\Users\Neal\Documents\PowerShell\Scripts\AdventOfCode\2022
IsContainer       : False             
Name              : day7_input.txt
Length            : 13172
#>
Measure-Command {
$PuzzleInput = Get-Content -Path C:\Users\Neal\Documents\PowerShell\Scripts\AdventOfCode\2022\day7_input.txt -Encoding UTF8

#First we'll process the input file to create workable filesystem objects for querying. We'll start by manually adding the root.
$RootFileSystemObject = [PSCustomObject]@{
    FullName = "/"
    ParentPath = ''
    IsContainer = $true
    Name = "/"
    Length = 0
}

$FileSystemObjects = @()
$FileSystemObjects += $RootFileSystemObject
$CurrentDirectory = ''

#Now we'll parse the puzzle input file
for($Iterator = 1; $Iterator -lt $PuzzleInput.Length; $Iterator++) {
    $LineItem = $PuzzleInput[$Iterator]

    #Check to see if it's a Change Directory command and update the directory accordingly
    if($LineItem -match '\$ cd ' ) {
        $DirectoryToChangeTo = ($LineItem -split '\$ cd ')[1]
        
        if($DirectoryToChangeTo -like "..") {$CurrentDirectory = ($CurrentDirectory -split '/' | Select-Object -SkipLast 1) -join '/'}
        else {$CurrentDirectory += "/$DirectoryToChangeTo"}
    }

    #Check to see if it's a List command and create file system objects accordingly. In this case, after determining it's a list command, we'll continue to traverse the file until we stumble upon the next command or the end of the file.
    elseif($LineItem -match '\$ ls') {
        $Iterator++
        $LineItem = $PuzzleInput[$Iterator]

        while($LineItem -notmatch '\$' -and $LineItem -notlike $null) {
            $Name = ($LineItem -split ' ')[1]
            $IsContainer = $LineItem -like 'dir *'

            if($CurrentDirectory -like $null) {
                $ParentPath = "/"
                $FullName = $ParentPath + "$Name"
            }

            else {
                $ParentPath = $CurrentDirectory
                $FullName = $ParentPath + "/$Name"
            }
            
            if($IsContainer) {[int]$Length = 0}
            else {[int]$Length = ($LineItem -split ' ')[0]}
            
            $FileSystemObject = [PSCustomObject]@{
                FullName = $FullName
                ParentPath = $ParentPath
                IsContainer = $IsContainer
                Name = $Name
                Length = $Length
            }

            $FileSystemObjects += $FileSystemObject

            #Since Directories don't typically have a Length, we're going to use that property to hold the total of all files contained within the directory by adding to it each time a file it contains is encountered.
            ($FileSystemObjects | Where-Object -Property FullName -Like $FileSystemObject.ParentPath).Length += $FileSystemObject.Length

            $Iterator++
            $LineItem = $PuzzleInput[$Iterator]
        }

        $Iterator--

    }

}

#Now add the total amount consumed by each directory to it's parent directory from the bottom to the top.
for($Iterator = $FileSystemObjects.Count - 1; $Iterator -gt 0; $Iterator--) {
    $FileSystemObject = $FileSystemObjects[$Iterator]
    if($FileSystemObject.IsContainer -like $true) {($FileSystemObjects | Where-Object -Property FullName -Like $FileSystemObject.ParentPath).Length += $FileSystemObject.Length}
}

#Then sum up the answer. The answer is the Sum.
$FileSystemObjects | Where-Object {$_.IsContainer -like $true -and $_.Length -le 100000} | Measure-Object -Property Length -Sum
<#
Count    : 34
Average  : 
Sum      : 1783610
Maximum  : 
Minimum  : 
Property : Length
#>
}
#Part2
#First we need to find the current free space. This will be as simple as adding up all the space used by the files, which we can tell are files if IsContainer is False, and subtracting it from the total space given.
$CurrentFreeSpace = 70000000 - ($FileSystemObjects | Where-Object -Property IsContainer -Like $false | Measure-Object -Property Length -Sum).Sum
#25640133
$ExtraFreeSpaceRequired = 30000000 - $CurrentFreeSpace
#4359867

#Now, since we already performed the directory calculations, we simply select the ones which will ensure that the extra free space obtained is greater than or equal to what's required, sort them, and select the first one.
#The Length of that directory is the answer.
$FileSystemObjects | Where-Object {$_.IsContainer -like $true -and $_.Length -ge $ExtraFreeSpaceRequired} | Sort-Object -Property Length | Select-Object -First 1
<#
FullName    : /nfn/qmrsvfvw/fpljqj/tdnp
ParentPath  : /nfn/qmrsvfvw/fpljqj
IsContainer : True
Name        : tdnp
Length      : 4370655
#>