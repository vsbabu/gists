"""
Python3 script that generates random math questions (add, sub, multiply, divide) and prints an HTML 
output. Redirect output to some file and open in browser.

I use this to generate 50 questions for children and use Amazon's send-to-kindle site to send to Kindle.
When opened in Kindle, the answer column is not visible. I give Kindle to children to copy questions to
a worksheet and once done, quickly check answers against the generated HTML opened on regular browser.
"""
from dataclasses import dataclass
from typing import List, Tuple
from random import choice
import datetime

@dataclass 
class PracticeQuestion:
    """Defines operations that can be used
    Each operation has two operands and the values here can be used to
    specify the minimum and maximum for each operand.
    """
    name: str
    symbol: str
    min_left: int
    max_left: int
    min_right: int
    max_right: int

    def __repr__(self) -> str:
        return (
            f'{self.name}=({self.min_left}..{self.max_left}) {self.symbol} ({self.min_right}..{self.max_right})'
        )
    
    def gen(self) -> Tuple[int, int]:
        l = choice(range(self.min_left, self.max_left))
        r = choice(range(self.min_right, self.max_right))
        return l, r

    # brute code - should be generalized if possible
    def result(self, left, right) -> List[int]:
        r = [None, None]
        match self.name:
            case "ADD":
                r[0] = left + right
            case "SUB":
                if (left >= right):
                    r[0] = left - right
            case "MUL":
                r[0] = left * right
            case "DIV":
                r[0] = left // right
                r[1] = left % right
        return r

    def pretty_question(self, i:Tuple[int, int]) -> str:
            return (
                f'{i[0]}{self.symbol}{i[1]}'
            )
    def pretty_result(self, r:List[int]) -> str:
        if r[1] is None:
            return (
                f'{r[0]}'
            )
        else:
            return (
                f'({r[0]}, {r[1]})'
            )


html = """
<html>
<head><title>Practice Questions {ts}</title>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
html, body {{
    height: 100%;
}}

html {{
    display: table;
    margin: auto;
}}

body {{
    display: table-cell;
    vertical-align: middle;
}}
/* Kindle Fire (All) Formatting */
@media amzn-kf8 
{{
span.wonw {{ color: white; display: none; }}
}}
@media amzn-mobi 
{{
span.wonw {{ color: white;  display: none; }}
}}
</style>

<head>
<body>
<h3>{ts}</h3>
<table class="defaultcontent" bordercolor="#999999" border="1" cellpadding="6" cellspacing="0"  align="left">
<thead>
<tr><th>#</th><th>Question</th><th></th></tr>
</thead>
<tbody>
{tbody}
</tbody>
</table>
</body>
</html>
"""
if __name__ == '__main__':

    operations: List[PracticeQuestion] = []
    operations.append(PracticeQuestion("ADD", "+", 101, 999, 101, 999))
    operations.append(PracticeQuestion("SUB", "-", 501, 999, 101, 500))
    operations.append(PracticeQuestion("MUL", "x", 101, 200, 5,25))
    operations.append(PracticeQuestion("DIV", "/", 101, 999, 10,25))

    tbody = ""
    for i in range(1, 51):
        o = choice(operations)
        s = o.gen()
        r = o.result(s[0], s[1])
        hs = o.pretty_question(s)
        hr = o.pretty_result(r)
        h = f'<tr><td align="right">{i}</td><td>{hs}</td><td><span class="wonw">{hr}</span></td></tr>'
        tbody = tbody + "\n" + h
        if (i % 10) == 0:
            tbody = tbody + """\n<tr><td colspan="3"><hr/></td></tr>"""

    print(html.format(ts=datetime.date.today(), tbody=tbody))