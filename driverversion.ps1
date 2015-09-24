<# Author : VM
This script collects Driver versions, Manufacture, Hw and Compat IDs 
This data is collected in a format amenable for diffing


#>

Param([String]$ResultsFile=$(throw "Please specify the file where you want the output"));  
  
if (Test-Path $ResultsFile)  
{  
	Remove-Item $ResultsFile;  
}  
  
  
function OutputLine([String]$OutLine)  
{  
    $OutLine | Out-File $ResultsFile -NoClobber -Append -Encoding "ASCII"  
}  
  
  
function StringInArray([string]$Name, [string[]] $Arr)  
{  
	foreach($st in $Arr)  
	{  
		if ($st -eq $Name)  
		{  
			return $true;  
		}  
	}  
	return $false;  
}  
  
#$drivers = gwmi Win32_PnpSignedDriver | Sort-Object -Property HardWareID, Description , Manufacturer, driverdate, driverversion, signer   
$drivers = gwmi Win32_PnpSignedDriver | Sort-Object -Property DeviceClass, HardWareID, DeviceName, Description , Manufacturer, driverdate, driverversion

$system_version = "$((Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion).$((Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber)"  
#Write-Host $system_version  
  
OutputLine "DeviceName,FriendlyName,DriverName, DriverVersion, DriverDate,  HardwareID, Manufacturer, DeviceClass"  
OutputLine "========================================================================================"  

$Index = 0;
foreach ($driver in $drivers)  
{  
	#[bool]$not_needed_deviceclasses = StringInArray -name $($driver.DeviceClass) -arr "LEGACYDRIVER";  
    [bool]$not_needed_deviceclasses = StringInArray -name $($driver.DeviceClass) -arr "LEGACYDRIVER","PROCESSOR","PRINTER","PRINTQUEUE";  
		
    [bool]$not_needed_data=$false;  
	  
	# Drivers where Manufacturer is Microsoft & are in build  
    #if (($driver.Manufacturer -eq "Microsoft") -and ($driver.DriverVersion -ne $null) -and ($driver.DriverVersion.StartsWith($system_version)))  	
	#{  
	#	$not_needed_data=$true;  
	#}  
    

    if ($driver.DriverVersion -ne $null -and $driver.DriverVersion.StartsWith($system_version))  
	{  
	   $driver.DriverVersion = "BuildNumber"  
	}  
  
#	OutputLine "Class:$($driver.DeviceClass),Mfg:$($driver.Manufacturer),$($driver.DeviceName),$($driver.DriverVersion),$($driver.HardwareID),$($driver.CompatID)";    
#	OutputLine "ID:$Index,Class:$($driver.DeviceClass),Mfg:$($driver.Manufacturer),Ver:$($driver.DriverVersion),HWID:$($driver.HardwareID),FriendlyName:$($driver.FriendlyName),CompatID:$($driver.CompatID)";  
	# Drivers that start with (Standard  
	if (($driver.Manufacturer -ne $null) -and ($driver.Manufacturer.StartsWith("(Standard")))  
	{  
		$not_needed_data=$true;  
	}  
	  
	
	if (($driver.DeviceClass -ne $null) -and ($driver.DeviceName -ne $null) -and ($driver.DeviceName -ne "") -and !$not_needed_data -and !$not_needed_deviceclasses)  
	{  
		$Index++;
#	    OutputLine "ID:$Index,Class:$($driver.DeviceClass),Mfg:$($driver.Manufacturer),Ver:$($driver.DriverVersion),Date:$($driver.DriverDate),HWID:$($driver.HardwareID),FriendlyName:$($driver.FriendlyName),CompatID:$($driver.CompatID)";  
	    OutputLine "DeviceName:$($driver.DeviceName),  FriendlyName:$($driver.FriendlyName), DriverName:$($driver.DriverName), Ver:$($driver.DriverVersion),Date:$($driver.DriverDate),HWID:$($driver.HardwareID), Mfg:$($driver.Manufacturer), Class:$($driver.DeviceClass)";  
  
#		OutputLine "$($driver.DeviceClass),$($driver.Manufacturer),$($driver.DeviceName),$($driver.DriverVersion)";  
	}  
}
OutputLine "Total Divers: $Index";  
  
  
# SIG # Begin signature block
# MIIhdQYJKoZIhvcTAQcCoIIhZjCCIWICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCEj9dyicf7kgJu
# a0ffXeGjU5KJyeHAfBE9DodyekYuzKCCCxswggSjMIIDi6ADAgECAgphBUlVAAAA
# AAALMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIw
# MTAwHhcNMTExMDEwMjA0NTI0WhcNMTMwMTEwMjA1NTI0WjCBgzELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEeMBwGA1UE
# AxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAz6QwMYFRFoblVcw0YLaWRSlfK+8IpNLWFyvzzgWw5XJDpMztm1w7
# HuQR6SpZ/ZxxcnggLJsaOIEei1ukYvP95AbI+H2NsdSvYQe66+hEnzmqzrKT3FT9
# S+AmRE9X8PjvIxpKagPmFPTp2Kk2rncUrbzw9ebaNPDyyk97ArBf1P4PdbiTOX1/
# Bo9hnVLknhLGsobI834GOtZ4yJQ9x0eIvycWxnKDj8//nnBX5DC42wYRJ2POYRUo
# lpZ/h5fQu2JkAkCLIr4rXrmjAXdy59NOfAITVX7AwAZcpql+QO423XRkr1cks1j2
# kGueVWcYWriQ6trHLuO0aao7udsl4QPW+wIDAQABo4IBGzCCARcwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwHQYDVR0OBBYEFGn4svcx+rliGINxWPuo4sL52HhhMB8GA1Ud
# IwQYMBaAFOb8X3u7IgBY5HJOtfQhdCMy5u+sMFYGA1UdHwRPME0wS6BJoEeGRWh0
# dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNp
# Z1BDQV8yMDEwLTA3LTA2LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKG
# Pmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENB
# XzIwMTAtMDctMDYuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggEB
# AHiKW+BabSN9dQmbkBeA+spqnSeqRdOShe+8Toa8vMSnZbndhdgMSrimlfAPh1N4
# QQqIMKSxIFQWFh4UoRYns1m0aMU4sB0uPxC/acNM/oMMnZhMeAqWu1C0Ok2S8gM/
# K5WTy8jZUj1NGGsZJlr9XGpAS6734dQxKMh86lSpoddwP3aAWRrQENr3/vYanwUw
# im7Aum39LgwkWDlNUmxq5NkG3wiAW0FTjXsCwVQxDcvC6KQFRBCFx0H5uwV+UoKE
# aT9jMuNL31c4rohYwpfU7tFAY+8tbWuwfCuRO/zoQrqKKxDFBznHQI3SESJRcLhB
# oB0B9goZYPyCJrDHqWPf2IUwggZwMIIEWKADAgECAgphDFJMAAAAAAADMA0GCSqG
# SIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkg
# MjAxMDAeFw0xMDA3MDYyMDQwMTdaFw0yNTA3MDYyMDUwMTdaMH4xCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBD
# b2RlIFNpZ25pbmcgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDpDmRQeWe1xOP9CQBMnpSs91Zo6kTYz8VYT6mldnxtRbrTOZK0pB75+WWC
# 5BfSj/1EnAjoZZPOLFWEv30I4y4rqEErGLeiS25JTGsVB97R0sKJHnGUzbV/S7Sv
# CNjMiNZrF5Q6k84mP+zm/jSYV9UdXUn2siou1YW7WT/4kLQrg3TKK7M7RuPwRknB
# F2ZUyRy9HcRVYldy+Ge5JSA03l2mpZVeqyiAzdWynuUDtWPTshTIwciKJgpZfwfs
# /w7tgBI1TBKmvlJb9aba4IsLSHfWhUfVELnG6Krui2otBVxgxrQqW5wjHF9F4xoU
# Hm83yxkzgGqJTaNqZmN4k9Uwz5UfAgMBAAGjggHjMIIB3zAQBgkrBgEEAYI3FQEE
# AwIBADAdBgNVHQ4EFgQU5vxfe7siAFjkck619CF0IzLm76wwGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
# VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
# AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJB
# dXRfMjAxMC0wNi0yMy5jcnQwgZ0GA1UdIASBlTCBkjCBjwYJKwYBBAGCNy4DMIGB
# MD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3Mv
# Q1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAA
# bwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUA
# A4ICAQAadO9XTyl7xBaFeLhQ0yL8CZ2sgpf4NP8qLJeVEuXkv8+/k8jjNKnbgbjc
# HgC+0jVvr+V/eZV35QLU8evYzU4eG2GiwlojGvCMqGJRRWcI4z88HpP4MIUXyDlA
# ptcOsyEp5aWhaYwik8x0mOehR0PyU6zADzBpf/7SJSBtb2HT3wfV2XIALGmGdj1R
# 26Y5SMk3YW0H3VMZy6fWYcK/4oOrD+Brm5XWfShRsIlKUaSabMi3H0oaDmmp19zB
# ftFJcKq2rbtyR2MX+qbWoqaG7KgQRJtjtrJpiQbHRoZ6GD/oxR0h1Xv5AiMtxUHL
# vx1MyBbvsZx//CJLSYpuFeOmf3Zb0VN5kYWd1dLbPXM18zyuVLJSR2rAqhOV0o4R
# 2plnXjKM+zeF0dx1hZyHxlpXhcK/3Q2PjJst67TuzyfTtV5p+qQWBAGnJGdzz01P
# tt4FVpd69+lSTfR3BU+FxtgL8Y7tQgnRDXbjI1Z4IiY2vsqxjG6qHeSF2kczYo+k
# yZEzX3EeQK+YZcki6EIhJYocLWDZN4lBiSoWD9dhPJRoYFLv1keZoIBA7hWBdz6c
# 4FMYGlAdOJWbHmYzEyc5F3iHNs5Ow1+y9T1HU7bg5dsLYT0q15IszjdaPkBCMaQf
# EAjCVpy/JF1RAp1qedIX09rBlI4HeyVxRKsGaubUxt8jmpZ1xTGCFbAwghWsAgEB
# MIGMMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNV
# BAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTACCmEFSVUAAAAAAAsw
# DQYJYIZIAWUDBAIBBQCggcIwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMK85icf
# le3s+sna8zrLrn7pCOnLFntlr6avs1PSxEmTMFYGCisGAQQBgjcCAQwxSDBGoCyA
# KgBBAGQAZAAtAEEAcABwAEQAZQB2AFAAYQBjAGsAYQBnAGUALgBwAHMAMaEWgBRo
# dHRwOi8vbWljcm9zb2Z0LmNvbTANBgkqhkiG9w0BAQEFAASCAQBK7RXkbaOlkbyt
# KJdaa1R3CtqCotF7fGlxZTsSfsnpULYqSqKNRo0rKvDFAR3hHkD7Ux81UnPr/4Xe
# wi+A3fAR8cGICPlrKZkENL0hW3AGzc3qhHLX0Ttj8NvMI7eQN/bTZGLVI+JonN7Z
# bLQfBzRriAFWO1FEpFG97Cap48szVdpLXbZuCJ/VbZgJUoykPJ5GacrJr57Vzjsw
# S+9KBw9JuE+g7ncqvtPZeY/1dYa8uDZK9A5zbPRUaInKZhvYtvfh1Irdlr7l09nS
# YWU1jHBBzdiGLiGm08CzKPSslpHuMbsdwr33mqoKFProailmPIYxiNBGI85UgcNR
# Qbt56tuOoYITLzCCEysGCisGAQQBgjcDAwExghMbMIITFwYJKoZIhvcNAQcCoIIT
# CDCCEwQCAQMxDzANBglghkgBZQMEAgEFADCCAT0GCyqGSIb3DQEJEAEEoIIBLASC
# ASgwggEkAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIBXiBKpQYLEU
# MseDCYk2K3/vyGRVKI4o/H5xzufGKlf1AgZP4zcsy+QYEzIwMTIwNzI3MDE0ODIw
# LjkxMlowBwIBAYACAfSggbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
# IEVTTjpCOEVDLTMwQTQtNzE0NDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh
# bXAgU2VydmljZaCCDsQwggZxMIIEWaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3
# DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
# MAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAx
# MDAeFw0xMDA3MDEyMTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# qR0NvHcRijog7PwTl/X6f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AV
# UycEMR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN
# 0Or1R4HNvyRgMlhgRvJYR4YyhB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvf
# YfxGwScdJGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZE
# fu/QS/1u5ZrKsajyeioKMfDaTgaRtogINeh4HLDpmc085y9Euqf03GS9pAHBIAmT
# eM38vMDJRF1eFpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAw
# HQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoA
# UwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQY
# MBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6
# Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1
# dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIw
# MTAtMDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9
# BggrBgEFBQcCARYxaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQ
# Uy9kZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8A
# bABpAGMAeQBfAFMAdABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOC
# AgEAB+aIUQ3ixuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn
# 8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZL
# dO9CEMivv3/Gf/I3fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQk
# IjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/d
# xUoLkSbiOewZSnFjnXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2e
# Gq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkea
# gMXQzafQ732D8OE7cQnfXXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fe
# cn5ha293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjm
# mC3qjeAzLhIp9cAvVCch98isTtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3Qy
# S99je/WZii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4Z
# OC+8z1gFLu8NoFA12u8JJxzVs341Hgi62jbb01+P3nSISRIwggTRMIIDuaADAgEC
# AgphB9RVAAAAAAAOMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTEyMDEwOTIxMzUzMVoXDTEzMDQwOTIxNDUzMVowgbMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# JzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMwQTQtNzE0NDElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAMHooomrwmklOcgDuyeyzKBYcs1L+EBnAvOUpehHViJ7
# IJyeP7j8/dgT5CaikO/kvYhKZTtYsHKFBIgETWlVyh2sc4P740z1XiaxUWcHbe5g
# 4QiEj0vyZs6NYD8YkPPckgaObvXgslt+cClC60IVpsVV8x692b3LE9nqsHS/e5uM
# Vgm5iGUklEzKgKTz7/LHt31Nt7ugP1OieY1s8bm4yeR11F7bXa3kVqU4oQxUOynL
# BMgeDK0ST/Kl3nOrGfR1AtB01AfhkVlqmyUYmAsox9d1YmmqQX6LO5GG/6T06rb3
# lYuZw6Ya7Ivo8bMoH+4MhTQSgVMHyMlvbwKmfOgXtA8CAwEAAaOCARswggEXMB0G
# A1UdDgQWBBTG1uZ1NVPv8J242LRL7l5TAQhj2TAfBgNVHSMEGDAWgBTVYzpcijGQ
# 80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0w
# MS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNy
# dDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# CwUAA4IBAQCNCgUjiemz+0FezgXN0Kq/TbkRPwN1xLQraDs+2U2AXBrMEsqUtKPn
# Now+eBpFEs/HjSCvxzcKYqSgr2KqfSk1IMOukkv69rheS190ZqzyoS1wOHHRmDZb
# vwbl/i3sidil6pdQQoK1NfsQeH8YXu22lFsfaOazfDdv+D/C+W+FpcNnJYTr2big
# o7TuWCapOsh9BEsMqBNGbZ7GWmDnCHGRG5SYnRNgrTO9Nn3tCGgiyDDn3yzEK/U/
# uIFZT6vtbLwgBhEFTDA5KEdQVN+5znPfkPNp/6gTE4J70BvaIKnBUObJG/+kgqJ/
# ml5hFro8XFEH06odIsY5Hd+OqNLgUx/coYIDdjCCAl4CAQEwgeOhgbmkgbYwgbMx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1P
# UFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMwQTQtNzE0NDElMCMG
# A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkGBSsOAwIa
# BQADFQCDFNfgAdRu2ciVMysWb59xJmVTJ6CBwjCBv6SBvDCBuTELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UE
# CxMebkNpcGhlciBOVFMgRVNOOkIwMjctQzZGOC0xRDg4MSswKQYDVQQDEyJNaWNy
# b3NvZnQgVGltZSBTb3VyY2UgTWFzdGVyIENsb2NrMA0GCSqGSIb3DQEBBQUAAgUA
# 07xeBTAiGA8yMDEyMDcyNzAwMjMzM1oYDzIwMTIwNzI4MDAyMzMzWjB0MDoGCisG
# AQQBhFkKBAExLDAqMAoCBQDTvF4FAgEAMAcCAQACAiC5MAcCAQACAhZUMAoCBQDT
# va+FAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwGgCjAIAgEAAgMW
# 42ChCjAIAgEAAgMHoSAwDQYJKoZIhvcNAQEFBQADggEBAB3pneQ0ummVSf520nkG
# d0cl91b8z4az719GlnsFmWn3NnH8rXCvGjUGJWSmN1ZBQR8pUaCxfx97cUqBL3Pc
# LNMwC3s1dgcBl/cYEQhEvyIbIAwP8/JVxRjSanbvLOGhf0zMNwW8gwU6pPOypN4I
# Rh9vTlN1D8LdbcGHsj1xG0wNSe4zxoDur6/9kiKVxanDMH7qmpCjGLNiiukUlIz9
# shweF7IxotKhH4DQ69B5x8GcevovSOrjk6UolkFE/FXRS70P6iYAn6ohUrNB1SJJ
# mA+1vrlzd7LYxcABRO4kbie8/DAEe5s4ZPPrG8JY6Rk3OGQn1WDv/6DuGsVWMOkr
# ILwxggLjMIIC3wIBATCBijB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIK
# YQfUVQAAAAAADjANBglghkgBZQMEAgEFAKCCASkwGgYJKoZIhvcNAQkDMQ0GCyqG
# SIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCD79sRsR9kBzA0cyuDI4mW/fW0R6LuK
# xTHKRA1D7ikPzDCB2QYLKoZIhvcNAQkQAgwxgckwgcYwgcMwgagEFIMU1+AB1G7Z
# yJUzKxZvn3EmZVMnMIGPMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACCmEH1FUAAAAAAA4wFgQUYNX48C2DvE5UesJgx5a/d4tsPlAwDQYJKoZIhvcN
# AQELBQAEggEAsdk2UVVehKtg/aGq029Y0sPh04xC9fiKR13QdR5Ked9I7l1M7Pin
# berhpY7b+0m4ME68wkfcZOfZFIf1nqbxMryRGv9yKhnbK1+sk+A+ykbPAgblgsPR
# fz3w9vHxr4Kf/UfUGQv+sL4z7ff28yOb9iMCK59miJwCT6Hv1bQjUxx4bTucKA6t
# kTBAC7Xn/hBWuxF+fUgL2eoKqDFDipHoRQLNXOiaJtzHNoGgN78Kvos5N1Kss3tC
# Z566Ht7Kdq1GAngaKbwFC7yNVb581AsKfi2DJc6NZ58AjoTuW0VHoHZjbZqS+c8n
# G0C+1JrgLkT/i2Zr9QG0r5NjErVLWRgMiA==
# SIG # End signature block
