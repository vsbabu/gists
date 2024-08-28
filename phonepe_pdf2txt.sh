#### this has some bugs w.r.t statement wrapping on long amounts, credits, HH24 etc. Use pure Python3 version below instead.
###                  https://gist.github.com/vsbabu/37275c9e45b8a496ed987e801950991a
#### retaining this for memory and not for use
############### DEPRECATED ##################################
# You need gnu awk and standard unix text tools
# PhonePe mails a PDF wih name PhonePe_Transaction_Statement.pdf. Open, Copy-all and paste it into a text file PhonePe_Transaction_Statement.txt
# If you are doing this in Windows, convert line endings first by running
#    dos2unix PhonePe_Transaction_Statement.txt
# Output of the script is a pipe separated file
# timestamp|payee|txnid|utr|source|amount
# NOTE header row is NOT printed
# NOTE amount assumes debit only; refunds and credits are not separated out
grep -v "^Page" -A 2 PhonePe_Transaction_Statement.txt | grep "Transaction ID :" -B 3 -A 3 | grep -v '^--' | awk '{
  fldnu = NR % 7
  fldval = $0
  if (fldnu == 0) fldnu = 7
  if (fldnu == 1) {
    if(rec) print rec
    rec = fldval
  }
  if (fldnu == 2) {
    rec = rec " " fldval # attach time to date field
    #change rec from eg: Aug 07, 2024 03:38 PM to yyyy-mm-dd hh24:mi
    gsub(/[ ,:]+/, " ", rec)
    split(rec, A, " ")
    if (A[6] == "PM") A[4] = A[4] + 12
    A[1] =  sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec",A[1])+2)/3)
    rec = A[3]"-"A[1]"-"A[2]" "A[4]":"A[5]
  }
  if (fldnu == 3) { #remove Paid to and Bill Paid
    sub(/Paid to /,"", fldval)
    sub(/Bill paid - /,"", fldval)
  }
  # if it is not debit, nuke the rec
  if (fldnu == 7)
    if (index(fldval, "Debit") == 0)
      rec = "" 
  if (fldnu >= 4) fldval = A[split(fldval, A, " ")] #Txn, UTR, paid by, amount only
  if (fldnu > 2 && rec ) rec = rec "|" fldval
}
END { if (rec) print rec }'