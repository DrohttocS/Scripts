function PingRange ($from, $to) {
    $from..$to | % {"192.168.10.$($_): $(Test-Connection -BufferSize 2 -TTL 5 -ComputerName 192.168.10.$($_ ) -quiet -count 1)"}
}