function Get-SomeCompsInfo {
    <#
    .SYNOPSIS
    Basic function to gather some WMI info
    .DESCRIPTION
    Basic function to gather some WMI info using CIM session to remote host
    .NOTES
    Author:    Krzysztof Zielinski
    Version:   0.01
    #>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('cn','Machine')]
        [string[]]$ComputerName,
        [switch]$AlternateCredentials
    )
    Begin {
        if ($AlternateCredentials -eq $true) {
            $Creds = Get-Credential 
        }
    }
    Process{
        foreach ($Computer in $ComputerName) {
            try{
                if ($Creds -ne $null) {
                    $sess = New-CimSession -ComputerName $Computer -Credential $Creds -ErrorAction Stop -ErrorVariable MyErr
                } else {
                    $sess = New-CimSession -ComputerName $Computer -ErrorAction Stop -ErrorVariable MyErr
                }
                $CS = Get-CimInstance -CimSession $sess -ClassName win32_OperatingSystem
                $props = [ordered]@{
                                    'CSCaption' = $CS.Caption
                                    'Manufacturer' = $CS.Manufacturer
                                    'SN' = $CS.SerialNumber
                                  }
                $out = New-Object -TypeName psobject -Property $props
                Write-Output $out
            } catch {
                Write-Warning "$($MyErr.ErrorRecord)"
            }
        }
    }
    End {

    }
}

