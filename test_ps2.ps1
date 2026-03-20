
$all=@();
$lines = Get-Content -Path 'Scripts-by-AleexLeDev.bat' -Encoding UTF8;
foreach ($line in $lines) {
    if ($line -match '^set\s+"t\[\d+\]=([^"]+)"') {
        $entry = $matches[1];
        if ( -not ($entry -match '^---:') ) {
            $p=$entry-split'~',2;
            $ls=$p[0];
            $d=if($p.Count-gt 1){($p[1]-replace':HIDDEN$','').Trim()}else{''};
            $c2=$ls.IndexOf(':');
            if($c2-ge 0){
                $lb=$ls.Substring(0,$c2).Trim();
                $nm=$ls.Substring($c2+1).Trim();
                if($lb-and $lb-ne'---'){
                    $all+=@{N=$nm;D=$d;L=$lb}
                }
            }
        }
    }
}
Write-Output $all.Count
Write-Output $all[0].N
