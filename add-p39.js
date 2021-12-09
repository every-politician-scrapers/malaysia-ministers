const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, position, startdate) => {
  qualifier = {
    P580: meta.cabinet.start,
  }

  reference = {
    P143: 'Q328',
    P4656: 'https://en.wikipedia.org/w/index.php?title=Ismail_Sabri_cabinet&oldid=1059178629',
    P813: new Date().toISOString().split('T')[0],
  }

  if(startdate)      qualifier['P580']  = startdate

  return {
    id,
    claims: {
      P39: {
        value: position,
        qualifiers: qualifier,
        references: reference,
      }
    }
  }
}
