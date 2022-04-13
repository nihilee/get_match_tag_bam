#[
samtools view $bam | grep -F -f $tag_file >> $outDir/tag.sam

samtools view -bS -o $outDir/tag.bam $outDir/tag.sam

java -jar /home/polysolver/binaries/SamToFastq.jar I=$outDir/tag.bam F=$outDir/tag.1.fastq F2=$outDir/tag.2.fastq VALIDATION_STRINGENCY=SILENT
#abc_v14.uniq  ~11M text

perl /home/polysolver/scripts/clean_unpaired_fastq.pl $outDir/tag.1.fastq

perl /home/polysolver/scripts/clean_unpaired_fastq.pl $outDir/tag.2.fastq
]#

import os
import strutils
import hts
import sets

proc tag_set(t: string): HashSet[string] = 
  var a: HashSet[string]
  for line in lines(t):
    a.incl(line)
  a

proc oneline(s: string, a: HashSet[string]): bool =
  var x: HashSet[string]
  for i in 0..s.len-38:
    x.incl(s[i..<i+38])
  # echo "record\n", s, "\nset1\n", x, "\nset2\n", a
  # 每一行和abc_v14.uniq都没有交集
  (x * a).len != 0

when isMainModule:
  let a = tag_set(paramStr(1))

  var b, ob: Bam
  open(b, cstring(paramStr(2)), index=true)
  open(ob, cstring(paramStr(3)), mode="w")
  ob.write_header(b.hdr)

  for record in b:
    let x = record.tostring.split("\t")[9]
    if oneline(x, a):
      ob.write(record)

  b.close()
  ob.close()