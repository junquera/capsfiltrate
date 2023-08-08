# Import-Module caps.ps1

# Enable Win32 loading
New-PSDrive -Name Win32 -PSProvider FileSystem -Root \\C:\Windows\System32

# Compile some quick C# so we can `P/Invoke` to the native library
$signature = @"
    [DllImport("USER32.dll")]                            
    public static extern short GetKeyState(int nVirtKey);
"@

if ( -Not "Win32.Kernel32" -as [type] ){
    $win32type = "Win32.Kernel32" -as [type]
} else {
    $win32type = Add-Type -MemberDefinition $signature -Name Kernel32 -Namespace Win32 -Passthru
}

# TODO Create namespace (e.g. Caps::) for the functions
function Is-CapsLock{

    # Check CapsLock
    $capsLock = [bool]( $win32type::GetKeyState(0x14) )

    return $capsLock
}

function Toggle-CapsLock{

    $wshell = New-Object -ComObject wscript.shell
    $wshell.SendKeys('{CAPSLOCK}')

}

function Set-CapsLock{

    param(
        [Parameter(Mandatory, Position=0)]
        [bool]$state
    )

    if ( -Not ($state -eq $(Is-CapsLock)) ){
        Toggle-CapsLock
    }

}


Export-ModuleMember -Function Is-CapsLock
Export-ModuleMember -Function Toggle-CapsLock
Export-ModuleMember -Function Set-CapsLock