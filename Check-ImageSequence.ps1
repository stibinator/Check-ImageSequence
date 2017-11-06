function Check-ImageSequence {
  Param ($searchFolder = ".\",
  [int]$StartFrame = 0,
  [switch]$removeDodgyPngs)
  $results = @{
    "firstFrameFound" = $null,
    "missing" = @(),
    "lastFrameFrameFound" = $null
  }
  $i=$StartFrame
  ls (get-item $searchFolder) | %{
    while (! ( $_.name -match ("{0}{1}" -f $i, $_.extension))){
      #write-host "missing frame $i" -ForegroundColor Red;
      $results.missing += $i;
      $i += 1;
    };
    #only do this once
    if ($results.firstFrameFound -eq $null){
      $results.firstFrameFound = $i
    }
    #do this the rest of the time
    $results.lastFrameFrameFound= $i;
    echo "checking $i";
    #wind back the cursor position so it doesn't scroll;
    [Console]::SetCursorPosition($Host.UI.RawUI.CursorPosition.X, $Host.UI.RawUI.CursorPosition.Y-1);
    if ($_.extension -eq ".png"){ #only check png files
      $badFile = ((pngcheck.exe $_.fullname 2>&1) -match "Error");
      if ($badFile){
        write-host "$_ is dodgy" -ForegroundColor Red;
        if ($removeDodgyPngs){ rm $_.fullname; }
      }
    }
    $i+=1;
  }
  return $results;
}
