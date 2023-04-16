const showdown = require('showdown');
const fs = require('fs');

const mdToHtml = (md) => {
  const file = fs.readFileSync(md, 'utf8');

  const converter = new showdown.Converter({
    simpleLineBreaks: true,
    completeHTMLDocument: true,
    flavor: 'github',
  });
  const html = converter.makeHtml(file);
  return html;
};

module.exports = { mdToHtml };
