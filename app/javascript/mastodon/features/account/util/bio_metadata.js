/*
  THIS IS A MESS BECAUSE EFFING MASTODON AND ITS EFFING HTML BIOS
  INSTEAD OF JUST STORING EVERYTHING IN PLAIN EFFING TEXT ! ! ! !
  BLANK LINES ALSO WON'T WORK BECAUSE RIGHT NOW MASTODON CONVERTS
  THOSE INTO `<P>` ELEMENTS INSTEAD OF LEAVING IT AS `<BR><BR>` !
  TL:DR; THIS IS LARGELY A HACK. WITH BETTER BACKEND STUFF WE CAN
  IMPROVE THIS BY BETTER PREDICTING HOW THE METADATA WILL BE SENT
  WHILE MAINTAINING BASIC PLAIN-TEXT PROCESSING. THE OTHER OPTION
  IS TO TURN ALL BIOS INTO PLAIN-TEXT VIA A TREE-WALKER, AND THEN
  PROCESS THE YAML AND LINKS AND EVERYTHING OURSELVES. THIS WOULD
  BE INCREDIBLY COMPLICATED, AND IT WOULD BE A MILLION TIMES LESS
  DIFFICULT IF MASTODON JUST GAVE US PLAIN-TEXT BIOS (WHICH QUITE
  FRANKLY MAKES THE MOST SENSE SINCE THAT'S WHAT USERS PROVIDE IN
  SETTINGS) TO BEGIN WITH AND LEFT ALL PROCESSING TO THE FRONTEND
  TO HANDLE ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
  ANYWAY I KNOW WHAT NEEDS TO BE DONE REGARDING BACKEND STUFF BUT
  I'M NOT SMART ENOUGH TO FIGURE OUT HOW TO ACTUALLY IMPLEMENT IT
  SO FEEL FREE TO @ ME IF YOU NEED MY IDEAS REGARDING THAT. UNTIL
  THEN WE'LL JUST HAVE TO MAKE DO WITH THIS MESSY AND UNFORTUNATE
  HACKING ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !

                                           with love,
                                           @kibi@glitch.social <3
*/

const NEW_LINE    = /(?:^|\r?\n|<br\s*\/?>)/g;
const YAML_OPENER = /---/;
const YAML_CLOSER = /(?:---|\.\.\.)/;
const YAML_STRING = /(?:"(?:[^"\n]){1,32}"|'(?:[^'\n]){1,32}'|(?:[^'":\n]){1,32})/g;
const YAML_LINE = new RegExp('\\s*' + YAML_STRING.source + '\\s*:\\s*' + YAML_STRING.source + '\\s*', 'g');
const BIO_REGEX = new RegExp(NEW_LINE.source + '*' + YAML_OPENER.source + NEW_LINE.source + '+(?:' + YAML_LINE.source + NEW_LINE.source + '+){0,4}' + YAML_CLOSER.source + NEW_LINE.source + '*');

export function processBio(data) {
  let props = { text: data, metadata: [] };
  let yaml = data.match(BIO_REGEX);
  if (!yaml) return props;
  else yaml = yaml[0];
  let start = props.text.indexOf(yaml);
  let end = start + yaml.length;
  props.text = props.text.substr(0, start) + props.text.substr(end);
  yaml = yaml.replace(NEW_LINE, '\n');
  let metadata = (yaml ? yaml.match(YAML_LINE) : []) || [];
  for (let i = 0; i < metadata.length; i++) {
    let result = metadata[i].match(YAML_STRING);
    if (result[0][0] === '"' || result[0][0] === '\'') result[0] = result[0].substr(1, result[0].length - 2);
    if (result[1][0] === '"' || result[1][0] === '\'') result[0] = result[1].substr(1, result[1].length - 2);
    props.metadata.push(result);
  }
  return props;
}