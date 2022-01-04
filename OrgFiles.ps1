#Parameters
param([string]$source="",[string]$destination="")

$source = Read-Host "Please enter a source file path"
$destination = Read-Host "Please enter a destination file path"

#Functions
#Make sure the path exists
function Check-Folder([string]$path, [switch]$create){
    $exists = Test-Path $path

    if(!$exists -and $create){
        #create the directory because it doesn't exist
        mkdir $path | out-null
        $exists = Test-Path $path
    }
    return $exists
}

#Check folder stats
function Display-FolderStats([string]$path){
 $files = dir $path -Recurse | where {!$_.PSIsContainer}
 $totals = $files | Measure-Object -Property length -sum
 $stats = "" | Select path,count,size
 $stats.path = $path
 $stats.count = $totals.count
 $stats.size = [math]::round($totals.sum/1MB,2)
 return $stats
}

$LogFile ='D:\testing.txt'
Start-Transcript -Path $LogFile -Force

#Checks the souce file is there
$sourceexists = Check-Folder $source

if (!$sourceexists){
    Write-Host "The source directory is not found. Script can not continue."
    Exit
}

#Checks the destination, if it does not exist it will be created
$destinationexists = Check-Folder $destination -create

if (!$destinationexists){
    Write-Host "The destination directory has failed to be created and cannot found. Script can not continue."
    Exit
}

$files = dir $source -Recurse | where {!$_.PSIsContainer}

foreach ($file in $files){
    $ext = $file.Extension.Replace(".","")
    $extdestdir = "$destination\$ext"

    #check to see if the folder exists, if not create it
    $extdestdirexists = Check-Folder $extdestdir -create

    if (!$extdestdirexists){
        Write-Host "The destination directory ($extdestdir) can't be created."
        Exit
    }

        Write-Host "Copying $File to $Destination"
    #copy file
    copy $file.fullname $extdestdir
}

#Display each target folder name with the file count and byte count for each folder.
$dirs = dir $destination | where {$_.PSIsContainer}

$allstats = @()
foreach($dir in $dirs){
    $allstats += Display-FolderStats $dir.FullName
}

$allstats | sort size -Descending

Stop-Transcript
Notepad $LogFile