$filein = "C:\Users\shord2126\Desktop\NuancePpowerPDFKeys.txt"
$fileout = 'C:\Users\shord2126\Desktop\NuancePpowerPDFKeys2.txt'

gc $filein | sort | get-unique > $fileout