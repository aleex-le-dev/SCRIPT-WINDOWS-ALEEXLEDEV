# Script de listage des films - execution silencieuse
$disque = "D:\"
$extensionsVideo = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.ogv')


function Test-DossierSaison {
    param([string]$nomDossier)
    $nomLower = $nomDossier.ToLower()
    $patterns = @('season', 'saison', 's01', 's02', 's03', 's04', 's05', 's06', 's07', 's08', 's09', 's10', 's1', 's2', 's3')
    foreach ($pattern in $patterns) {
        if ($nomLower -like "*$pattern*") {
            return $true
        }
    }
    return $false
}

$sortie = "Liste des films - $disque`n"
$sortie += "=" * 80
$sortie += "`n`n"
$dossiersSeriesTraites = @()
$compteur = 0

Write-Host ""

Get-ChildItem -Path $disque -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $compteur++
    if ($compteur % 50 -eq 0) {
        Write-Host "." -NoNewline -ForegroundColor Green
    }
    
    $dossierActuel = $_.FullName
    
    # Ignorer le dossier Alex
    if (($dossierActuel -like "*\Alex") -or ($dossierActuel -like "*\Alex\*")) {
        if (($dossierActuel -like "*\Alex") -and ($dossierActuel -notlike "*\Alex\*")) {
            $sortie += "`nDossier: $dossierActuel (Dossier personnel - contenu masque)`n"
            $sortie += "-" * 80
            $sortie += "`n"
        }
        return
    }
    
    # Vérifier si on est dans un sous-dossier de série déjà traité
    $skipDossier = $false
    foreach ($dossierSerie in $dossiersSeriesTraites) {
        if (($dossierActuel.StartsWith($dossierSerie)) -and ($dossierActuel -ne $dossierSerie)) {
            $skipDossier = $true
            break
        }
    }
    if ($skipDossier) {
        return
    }
    
    # Récupérer les sous-dossiers
    $sousDossiers = Get-ChildItem -Path $dossierActuel -Directory -ErrorAction SilentlyContinue
    
    # Vérifier si c'est une série
    $estSerie = $false
    foreach ($sousDossier in $sousDossiers) {
        if (Test-DossierSaison -nomDossier $sousDossier.Name) {
            $estSerie = $true
            break
        }
    }
    
    if ($estSerie) {
        $sortie += "`nSerie TV: $dossierActuel`n"
        $sortie += "-" * 80
        $sortie += "`n"
        
        $totalEpisodes = 0
        $tailleTotale = 0
        $nbSaisons = 0
        
        foreach ($sousDossier in $sousDossiers) {
            if (Test-DossierSaison -nomDossier $sousDossier.Name) {
                $nbSaisons++
                $episodes = Get-ChildItem -Path $sousDossier.FullName -File -ErrorAction SilentlyContinue | Where-Object { $extensionsVideo -contains $_.Extension.ToLower() }
                $totalEpisodes += $episodes.Count
                foreach ($ep in $episodes) {
                    $tailleTotale += $ep.Length
                }
            }
        }
        
        $tailleTotaleGB = [math]::Round($tailleTotale / 1GB, 2)
        $sortie += "  Saisons: $nbSaisons`n"
        $sortie += "  Episodes total: $totalEpisodes`n"
        $sortie += "  Taille totale: $tailleTotaleGB GB`n"
        $dossiersSeriesTraites += $dossierActuel
    }
    else {
        # Lister les films du dossier
        $films = Get-ChildItem -Path $dossierActuel -File -ErrorAction SilentlyContinue | Where-Object { $extensionsVideo -contains $_.Extension.ToLower() }
        
        if ($films.Count -gt 0) {
            $sortie += "`nDossier: $dossierActuel`n"
            $sortie += "-" * 80
            $sortie += "`n"
            
            $tailleTotale = 0
            $filmsTriees = $films | Sort-Object Name
            foreach ($film in $filmsTriees) {
                $taille = $film.Length
                $tailleGB = [math]::Round($taille / 1GB, 2)
                $tailleTotale += $taille
                $nomFilm = $film.Name
                $sortie += "  - $nomFilm ($tailleGB GB)`n"
            }
            
            $tailleTotaleGB = [math]::Round($tailleTotale / 1GB, 2)
            $nbFilms = $films.Count
            $sortie += "Total: $nbFilms film(s) - $tailleTotaleGB GB`n"
        }
    }
}

# Sauvegarder dans un fichier
$cheminFichier = Join-Path -Path $PSScriptRoot -ChildPath "liste_films.txt"
$sortie | Out-File -FilePath $cheminFichier -Encoding UTF8 -Force

Write-Host ""
Write-Host ""
Write-Host "Termine ! Fichier cree : $cheminFichier" -ForegroundColor Green
Write-Host ""
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")