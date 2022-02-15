$storageAccountKey = "#storageKey"
$storageAccountName = "#storageAccount"
$tableName = "#tableName"
$partitionKey = '#partitionKey'
$Path = "#csvFilePath"

# set a storage context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$table = (Get-AzStorageTable -Name $tableName -Context $ctx).cloudtable
$partitionKey = 'pricesheet'

[Microsoft.Azure.Cosmos.Table.TableBatchOperation] $batchOperation = New-Object -TypeName Microsoft.Azure.Cosmos.Table.TableBatchOperation

$filepath = Import-Csv -Path $Path
$totalcount = $filepath.count
Write-Host $filepath.count
$batchCount = 0 # Initialize Batch count


foreach ($rowKey in 0..$totalcount) {
    $entity = New-Object Microsoft.Azure.Cosmos.Table.DynamicTableEntity -ArgumentList $partitionKey, $rowKey
    # Adding a dummy property Key, Value style
    $entity.Properties.add("Service", $filepath[$rowKey].Service)  
    $entity.Properties.add("IncludedQuantity", $filepath[$rowKey].IncludedQuantity)
    $entity.Properties.add("UnitofMeasure", $filepath[$rowKey].UnitofMeasure)
    #$entity.Properties.add("PartNumber", "$rowKey.PartNumber")
    $entity.Properties.add("UnitPrice", $filepath[$rowKey].UnitPrice)
    # Add to batch collection
    $batchOperation.InsertOrReplace($entity)

    # Maximum number of items per batch is 100
    # Execute batch, when collection = 100 items
    if ($batchCount -eq 10 ) {
        $table.ExecuteBatchAsync($batchOperation)
        # Initialize bach collection variable object and $batchCount
        [Microsoft.Azure.Cosmos.Table.TableBatchOperation] $batchOperation = New-Object -TypeName Microsoft.Azure.Cosmos.Table.TableBatchOperation
        $batchCount = 0
    }
    # If the last collection ot items is less than 100, execute here
    $batchCount++
    if ($batchOperation.Count -ne 0) {
        $table.ExecuteBatchAsync($batchOperation)
    }
}
