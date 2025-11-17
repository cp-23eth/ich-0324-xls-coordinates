BeforeAll {
    . './XlsCoordinatesConverter.ps1'
    Write-Host "Début des tests pour ConvertFrom-XlsCoordinates..."
}

Describe "convertFrom-XlsCoordinates" {
    # Tests pour les valeurs données
    It "should convert to correct coordinates" {
        ConvertFrom-XlsCoordinates -Cell "A1" | Should -Be @('Column = 1; Row = 1')
        ConvertFrom-XlsCoordinates -Cell "Cc3" | Should -Be @('Column = 81; Row = 3')
        ConvertFrom-XlsCoordinates -Cell "ANC34" | Should -Be @('Column = 1043; Row = 34')
        ConvertFrom-XlsCoordinates -Cell "XFD1048576" | Should -Be @('Column = 16384; Row = 1048576')
    }
    
    It "should throw error for invalid cell format" {
        { ConvertFrom-XlsCoordinates -Cell "A0" } | Should -Throw "Le format de la cellule 'A0' n'est pas valide. Utilisez le format 'A1', 'B2', etc."
        { ConvertFrom-XlsCoordinates -Cell "A1048577" } | Should -Throw "Le numéro de ligne doit être entre 1 et 1048576. '1048577' est invalide."
        { ConvertFrom-XlsCoordinates -Cell "XFE1" } | Should -Throw "Le format des lettres maximum est 'XFD'. '16385' est invalide."
        { ConvertFrom-XlsCoordinates -Cell "" } | Should -Throw "Cannot bind argument to parameter 'Cell' because it is an empty string."
        foreach ($cell in @("1A", "AA", "11")) {
            { ConvertFrom-XlsCoordinates -Cell $cell } | Should -Throw "Le format de la cellule '$cell' n'est pas valide. Utilisez le format 'A1', 'B2', etc."
        }
    }

    # Tests Split_column_row
    It "should split column and row correctly" {
        Split_column_row -cell "A1" | Should -Be @("A", "1")
        Split_column_row -cell "Cc3" | Should -Be @("CC", "3")
        Split_column_row -cell "ANC34" | Should -Be @("ANC", "34")
        Split_column_row -cell "XFD1048576" | Should -Be @("XFD", "1048576")
    }

    # Tests Convert_to_ASCII
    It "should convert letters to ASCII values correctly" {
        Convert_to_ASCII "A" | Should -Be 1
        Convert_to_ASCII "Z" | Should -Be 26
        Convert_to_ASCII "C" | Should -Be 3
        Convert_to_ASCII "X" | Should -Be 24
        Convert_to_ASCII "F" | Should -Be 6
        Convert_to_ASCII "D" | Should -Be 4
    }

    # Tests Calculate_column_number
    It "should calculate column number correctly" {
        Calculate_column_number -letter_ascii 1 -coordinateX 0 | Should -Be 1   # A
        Calculate_column_number -letter_ascii 3 -coordinateX 1 | Should -Be 29  # AC
        Calculate_column_number -letter_ascii 14 -coordinateX 29 | Should -Be 768 # ANC
        Calculate_column_number -letter_ascii 4 -coordinateX 630 | Should -Be 16384 # XFD
    }

    # Tests Test-ConvertFromXlsCoordinates
    It "should validate coordinates correctly" {
        { Test-ConvertFromXlsCoordinates -coordinateX 0 -row 1 } | Should -Throw "Le format des lettres minimum est 'A'. '0' est invalide."
        { Test-ConvertFromXlsCoordinates -coordinateX 16385 -row 1 } | Should -Throw "Le format des lettres maximum est 'XFD'. '16385' est invalide."
        { Test-ConvertFromXlsCoordinates -coordinateX 1 -row 0 } | Should -Throw "Le numéro de ligne doit être entre 1 et 1048576. '0' est invalide."
        { Test-ConvertFromXlsCoordinates -coordinateX 1 -row 1048577 } | Should -Throw "Le numéro de ligne doit être entre 1 et 1048576. '1048577' est invalide."
        { Test-ConvertFromXlsCoordinates -coordinateX 1 -row 1 } | Should -Not -Throw
        { Test-ConvertFromXlsCoordinates -coordinateX 16384 -row 1048576 } | Should -Not -Throw
    }
}
