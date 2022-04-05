$response = Invoke-RestMethod "https://api.thecatapi.com/v1/breeds"


$final_output = @()

foreach ($item in $response) {

    if ($null -ne $item.image) {
        $object = [PSCustomObject]@{
            Name     = $item.name
            owner    = $item.weight
            products = $item.image
        }
        $final_output += $object
    }else {
        $object = [PSCustomObject]@{
            Name     = $item.name
            owner    = $item.weight
            products = $item.image
        }
        $final_output += $object
    }
}


$final_output | Export-Csv .\testing1.csv -NoClobber
