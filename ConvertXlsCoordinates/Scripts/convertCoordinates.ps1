function ConvertFrom-XlsCoordinates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Cell
    )

    process {
        # [int]$coordinateX = 0

        $letters, $row = Split_column_row -cell $Cell

        foreach ($letter in $letters.ToCharArray()) {
            $letter_ascii = Convert_to_ASCII($letter) # Conversion en ASCII

            [int]$coordinateX = Calculate_column_number -letter_ascii $letter_ascii -coordinateX $coordinateX
        }

        # Tests
        Test-ConvertFromXlsCoordinates $coordinateX $row

        return @($coordinateX, $row)
    }
}

function Split_column_row() {
    param (
        [string]$cell
    )

    if ($cell -match '^([A-Z]+)([1-9]\d*)$') {
        return @($matches[1].ToUpper(), $matches[2])
    }
    else {
        throw "Le format de la cellule '$cell' n'est pas valide. Utilisez le format 'A1', 'B2', etc."
    }
}

function Convert_to_ASCII($char) {
    return [int][char]$char - [int][char]'A' + 1
}

function Calculate_column_number($letter_ascii, $coordinateX) {
    return $coordinateX * 26 + $letter_ascii
}

function Test-ConvertFromXlsCoordinates($coordinateX, $row) {
    if ([int]$coordinateX -gt 16384) {
        throw "Le format des lettres maximum est 'XFD'. '$coordinateX' est invalide."
    }
    if ([int]$coordinateX -lt 1) {
        throw "Le format des lettres minimum est 'A'. '$coordinateX' est invalide."
    }
    if ([int]$row -gt 1048576 -or [int]$row -lt 1) {
        throw "Le numéro de ligne doit être entre 1 et 1048576. '$row' est invalide."
    }
}