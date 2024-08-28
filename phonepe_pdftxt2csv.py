"""
PhonePe mails a PDF wih name PhonePe_Transaction_Statement.pdf. Open, Copy-all
and paste it into a text file.

Now call the script with input files listed out or with shell wildcards.
    python %s PhonePe_Text_File_1.txt PhonePe_Text_File_2.txt ...

For each input file, a corresponding .psv file will be created. The content of these
have the following format. 
   ts|payee|txnid|utr|source|kind|currency|amount

NOTE Records from each file are accumulated in memory before writing to output. So if you have a
     very large file, you need sufficient memory.
"""

import re
import traceback
import logging
import datetime
import sys
import glob
from dataclasses import dataclass, fields
from typing import List

START_OF_RECORD_MARKER = re.compile(r'^[A-Z][a-z][a-z]\s\d{2},\s20\d{2}$') #we've a Y2.1K problem
AMOUNT_MARKER = re.compile(r'[\d]+\.[\d]{2}$')

@dataclass
class PhonePeTxn:
    """A record from the statement"""
    ts: datetime.datetime = datetime.datetime.now()
    payee: str  = ""
    txn_id: str = ""
    utr_no: str = ""
    payer: str  = ""
    kind: str   = ""
    currency: str = ""
    amount: float = 0.0

    def header(sep="|"):
        return sep.join([field.name for field in fields(PhonePeTxn)])

    def to_list(self):
        return [
            self.ts.isoformat(),
            self.payee,
            self.txn_id,
            self.utr_no,
            self.payer,
            self.kind,
            self.currency,
            "%.02f" % self.amount
        ]
    def to_xsv(self, sep="|"):
        """Note - doesn't handle escaping separator"""
        return sep.join(self.to_list())


def mk_record(r):
    # chop the record at last amount field after 7th
    len_r = len(r) 
    for i in range(6, len_r):
        if AMOUNT_MARKER.search(r[i]):
            r = r[:i+1]
            break
    len_r = len(r) 
    nr = PhonePeTxn()
    nr.ts = datetime.datetime.strptime(r[0] + " " + r[1], "%b %d, %Y %I:%M %p")
    nr.payee = " ".join(r[2].split()[2:]).replace("- ","").strip()
    nr.txn_id = r[3].split()[-1]
    nr.utr_no = r[4].split()[-1]
    nr.payer = r[5].split()[-1]
    nr.kind = r[6].split()[0]
    nr.currency = r[6].split()[1]
    try:
        if (len_r == 8):
            nr.amount = float((r[7]))
        else:
            nr.amount = float(r[6].split()[-1])
    except Exception as e:
        logging.error(traceback.format_exc())
        logger.error(r)
        logger.error(len(r))
    return nr

logger = logging.getLogger(__name__)
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    if len(sys.argv) == 1:
       print(__doc__ % sys.argv[0]) 
       sys.exit(1)
    infiles = [f for l in sys.argv[1:] for f in glob.glob(l)]
    for infile in infiles:
        outfile = infile.replace('.txt','.psv')
        pagenu = 0
        recnu = 0
        records: List[PhonePeTxn] = [] 

        with open(infile, 'r') as fi:
            line = fi.readline()
            rec = []
            while line:
                l = line.strip()
                if START_OF_RECORD_MARKER.search(l):
                    if recnu > 0:
                        rec = mk_record(rec)
                        records.append(rec)
                        logger.debug(rec.to_xsv())
                        logger.debug("</RECORD %d>" % (recnu))
                        rec = []
                    rec = [l]
                    recnu += 1
                    logger.debug("<RECORD %d>" % (recnu))
                else:
                    lr = len(rec) 
                    if lr >= 1:
                        rec.append(l)
                line = fi.readline()
            rec = mk_record(rec)
            records.append(rec)
            logger.debug(rec.to_xsv())
            logger.debug("</RECORD %d>" % (recnu))

        with open(outfile, 'w') as fo:
            fo.write(PhonePeTxn.header(sep = "|") + "\n")
            for rec in records:
                fo.write(rec.to_xsv(sep = "|") + "\n")
        logger.info("Created %s with %d records" % (outfile, recnu))