#I'm going to solve this one with a multidimensional array so that the lookups will be an easy to read line

$PuzzleInput = Get-Content -Path C:\Users\Neal\Documents\PowerShell\Scripts\AdventOfCode\2022\day8_input.txt -Encoding UTF8
$NumberOfTreesNorthToSouth = $PuzzleInput.Count
$NumberOfTreesEastToWest = $PuzzleInput[0].Length
[PSCustomObject[,]]$Forest = [PSCustomObject[,]]::new($NumberOfTreesNorthToSouth,$NumberOfTreesEastToWest)

#Populate the forest with tree objects containing coordinates, tree height, and direction of visibility (from the perspective of the tree, this states from which direction the tree can be seen from the outer edge).
for($RowOfTrees = 0; $RowOfTrees -lt $NumberOfTreesNorthToSouth; $RowOfTrees++) {
    for($IndividualTree = 0; $IndividualTree -lt $NumberOfTreesEastToWest; $IndividualTree++) {
        $Height = $PuzzleInput[$RowOfTrees][$IndividualTree]
        
        [PSCustomObject]$TreeInForest = @{
            Coordinates = [int]$RowOfTrees,[int]$IndividualTree
            Height = $Height
            DirectionOfVisibility = [System.Collections.Generic.List[string]]@()
            ScenicScore = 0
        }

        $Forest[$RowOfTrees,$IndividualTree] = $TreeInForest
                
    }

}

function Verify-TreeVisibility ($TreeInForest, $Perspective, $NumberOfTreesNorthToSouth, $NumberOfTreesEastToWest) {

    if($Perspective -like "North") {
        #Any tree in the first row is visible from the North.
        if($TreeInForest.Coordinates[0] -eq 0) {$IsVisible = $true}
        
        #Otherwise, we must actually look at the rest of the trees to find out. Is there a tree larger than the current tree in the current tree's column between the current tree and the edge?
        else {
            $OuterEdge = 0
            $CurrentTreeColumn = $TreeInForest.Coordinates[1]
            $IsVisible = ($OuterEdge..($TreeInForest.Coordinates[0] - 1) | ForEach-Object {$Forest[$_,$CurrentTreeColumn]} | Where-Object {$_.Height -ge $TreeInForest.Height}).Count -eq 0
        }

        if($IsVisible) {$Forest[$TreeInForest.Coordinates[0],$TreeInForest.Coordinates[1]].DirectionOfVisibility.Add("North")}
    }
    
    elseif($Perspective -like "South") {
        #Any tree in the last row is visible from the South.
        if($TreeInForest.Coordinates[0] -eq ($NumberOfTreesNorthToSouth - 1)) {$IsVisible = $true}

        #Otherwise, we must actually look at the rest of the trees to find out. Is there a tree larger than the current tree in the current tree's column between the current tree and the edge?
        else {
            $OuterEdge = $NumberOfTreesNorthToSouth - 1
            $CurrentTreeColumn = $TreeInForest.Coordinates[1]
            $IsVisible = ($OuterEdge..($TreeInForest.Coordinates[0] + 1) | ForEach-Object {$Forest[$_,$CurrentTreeColumn]} | Where-Object {$_.Height -ge $TreeInForest.Height}).Count -eq 0
        
        }

        if($IsVisible) {$Forest[$TreeInForest.Coordinates[0],$TreeInForest.Coordinates[1]].DirectionOfVisibility.Add("South")}

    }

    elseif($Perspective -like "East") {
        #Any tree in the last column is visible from the East.
        if($TreeInForest.Coordinates[1] -eq ($NumberOfTreesEastToWest - 1)) {$IsVisible = $true}

        #Otherwise, we must actually look at the rest of the trees to find out. Is there a tree larger than the current tree in the current tree's row between the current tree and the edge?
        else {
            $OuterEdge = $NumberOfTreesEastToWest - 1
            $CurrentTreeRow = $TreeInForest.Coordinates[0]
            $IsVisible = ($OuterEdge..($TreeInForest.Coordinates[1] + 1) | ForEach-Object {$Forest[$CurrentTreeRow,$_]} | Where-Object {$_.Height -ge $TreeInForest.Height}).Count -eq 0
        
        }

        if($IsVisible) {$Forest[$TreeInForest.Coordinates[0],$TreeInForest.Coordinates[1]].DirectionOfVisibility.Add("East")}

    }

    elseif($Perspective -like "West") {
        #Any tree in the first column is visible from the West.
        if($TreeInForest.Coordinates[1] -eq 0) {$IsVisible = $true}

        #Otherwise, we must actually look at the rest of the trees to find out. Is there a tree larger than the current tree in the current tree's row between the current tree and the edge?
        else {
            $OuterEdge = 0
            $CurrentTreeRow = $TreeInForest.Coordinates[0]
            $IsVisible = ($OuterEdge..($TreeInForest.Coordinates[1] - 1) | ForEach-Object {$Forest[$CurrentTreeRow,$_]} | Where-Object {$_.Height -ge $TreeInForest.Height}).Count -eq 0
        
        }

        if($IsVisible) {$Forest[$TreeInForest.Coordinates[0],$TreeInForest.Coordinates[1]].DirectionOfVisibility.Add("West")}

    }

}

$Perspectives = "North","South","East","West"
#Populate the DirectionOfVisibility property of each tree
foreach($Perspective in $Perspectives) {
    foreach($TreeInForest in $Forest) {
        Verify-TreeVisibility -TreeInForest $TreeInForest -Perspective $Perspective -NumberOfTreesNorthToSouth $NumberOfTreesNorthToSouth -NumberOfTreesEastToWest $NumberOfTreesEastToWest
    }
}


#Now just count the number of objects where the property DirectionOfVisibility is not empty.
#The Count is the answer.
$Forest | Where-Object {$_.DirectionOfVisibility.Count -ne 0} | Measure-Object
<#
Count    : 1688
Average  : 
Sum      : 
Maximum  : 
Minimum  : 
Property : 
#>

function Calculate-ScenicScore ($TreeInForest, $NumberOfTreesNorthToSouth, $NumberOfTreesEastToWest) {
    
    #No calculations required if it's on the edge
    if($TreeInForest.Coordinates[0] -eq 0) {return 0}
    elseif($TreeInForest.Coordinates[0] -eq ($NumberOfTreesNorthToSouth - 1)) {return 0}
    elseif($TreeInForest.Coordinates[1] -eq ($NumberOfTreesEastToWest - 1)) {return 0}
    elseif($TreeInForest.Coordinates[1] -eq 0) {return 0}

    #Up
    $OuterEdge = 0
    $StartingRow = $TreeInForest.Coordinates[0] - 1
    $CurrentTreeColumn = $TreeInForest.Coordinates[1]

    for($UpScenicScore = 0; ($StartingRow - $UpScenicScore) -ge $OuterEdge; $UpScenicScore++) {

        if($TreeInForest.Height -le $Forest[($StartingRow - $UpScenicScore),$CurrentTreeColumn].Height) {$UpScenicScore++; break}
    }
   
    #Down
    $OuterEdge = $NumberOfTreesNorthToSouth - 1
    $StartingRow = $TreeInForest.Coordinates[0] + 1
    $CurrentTreeColumn = $TreeInForest.Coordinates[1]

    for($DownScenicScore = 0; ($StartingRow + $DownScenicScore) -le $OuterEdge; $DownScenicScore++) {
  
        if($TreeInForest.Height -le $Forest[($StartingRow + $DownScenicScore),$CurrentTreeColumn].Height) {$DownScenicScore++; break}
    
    }

    #Left
    $OuterEdge = 0
    $StartingColumn = $TreeInForest.Coordinates[1] - 1
    $CurrentTreeRow = $TreeInForest.Coordinates[0]

    for($LeftScenicScore = 0; ($StartingColumn - $LeftScenicScore) -ge $OuterEdge; $LeftScenicScore++) {
        
        if($TreeInForest.Height -le $Forest[$CurrentTreeRow,($StartingColumn - $LeftScenicScore)].Height) {$LeftScenicScore++; break}
    }

    #Right
    $OuterEdge = $NumberOfTreesEastToWest - 1
    $StartingColumn = $TreeInForest.Coordinates[1] + 1
    $CurrentTreeRow = $TreeInForest.Coordinates[0]

    for($RightScenicScore = 0; ($StartingColumn + $RightScenicScore) -le $OuterEdge; $RightScenicScore++) {
        
        if($TreeInForest.Height -le $Forest[$CurrentTreeRow,($StartingColumn + $RightScenicScore)].Height) {$RightScenicScore++; break}
    }

    return $UpScenicScore * $DownScenicScore * $LeftScenicScore * $RightScenicScore
}

#Part2
#Calculate the Scenic Scores
$Forest | ForEach-Object { $_.ScenicScore = Calculate-ScenicScore -TreeInForest $_ -NumberOfTreesNorthToSouth $NumberOfTreesNorthToSouth -NumberOfTreesEastToWest $NumberOfTreesEastToWest }

#Select the one which is the highest
$Forest.ScenicScore | Sort-Object -Descending | Select-Object -First 1
#410400